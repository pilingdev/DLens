import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as math;
import '../models/prediction_result.dart';
import '../utils/constants.dart';

// ─────────────────────────────────────────────────────────────────────────
// Top-level helpers — must be top-level so they cross isolate boundaries.
// ─────────────────────────────────────────────────────────────────────────

/// Payload sent to the background preprocessing isolate.
///
/// All fields are primitive/immutable so they serialise across isolates
/// safely.
///
/// NOTE: This service now targets the float32 YOLOv11 export exclusively.
/// There is no quantization branch — the model's input tensor is always
/// FLOAT32, so the only per-model variable left is layout (NCHW vs NHWC).
class _PreprocessPayload {
  final Uint8List imageBytes;
  final int targetSize;

  /// True when the model's input layout is NCHW [1, 3, H, W].
  /// False when NHWC [1, H, W, 3].
  final bool isNchw;

  const _PreprocessPayload({
    required this.imageBytes,
    required this.targetSize,
    required this.isNchw,
  });
}

/// Result returned from the preprocessing isolate.
class _PreprocessResult {
  /// Flat FLOAT32 tensor buffer, normalized to [0, 1]. Layout matches the
  /// model's native input shape (NCHW or NHWC).
  final Float32List float32Buffer;

  final int dx;
  final int dy;
  final double ratio;
  final int imgW;
  final int imgH;

  const _PreprocessResult({
    required this.float32Buffer,
    required this.dx,
    required this.dy,
    required this.ratio,
    required this.imgW,
    required this.imgH,
  });
}

/// Letterboxes the image and converts pixels into a normalized [0, 1]
/// FLOAT32 buffer matching the model's native input layout.
///
/// Runs entirely in a background isolate; never blocks the UI thread.
_PreprocessResult _preprocessIsolate(_PreprocessPayload payload) {
  // ── Decode & correct EXIF orientation ─────────────────────────────────
  img.Image? original = img.decodeImage(payload.imageBytes);
  if (original == null) throw Exception('Could not decode image');
  original = img.bakeOrientation(original);

  // ── Letterbox resize ───────────────────────────────────────────────────
  final int targetSize = payload.targetSize;
  final double ratio = targetSize / math.max(original.width, original.height);
  final int newUnpadW = (original.width * ratio).round();
  final int newUnpadH = (original.height * ratio).round();

  final resized = img.copyResize(
    original,
    width: newUnpadW,
    height: newUnpadH,
    interpolation: img.Interpolation.linear,
  );

  // Fill canvas with grey (114) and paste resized image centred.
  final padded = img.Image(width: targetSize, height: targetSize);
  img.fill(padded, color: img.ColorRgb8(114, 114, 114));
  final int dx = ((targetSize - newUnpadW) / 2).round();
  final int dy = ((targetSize - newUnpadH) / 2).round();
  img.compositeImage(padded, resized, dstX: dx, dstY: dy);

  final int W = padded.width; // matches payload.targetSize (e.g. 960)
  final int H = padded.height; // matches payload.targetSize (e.g. 960)
  const int C = 3; // RGB

  // ── Build the FLOAT32 buffer (normalized to [0, 1]) ───────────────────
  final Float32List buffer = Float32List(1 * C * H * W);

  if (payload.isNchw) {
    // ── NCHW: index = c*H*W + y*W + x ─────────────────────────────────
    for (int y = 0; y < H; y++) {
      for (int x = 0; x < W; x++) {
        final pixel = padded.getPixel(x, y);
        buffer[0 * H * W + y * W + x] = pixel.r / 255.0;
        buffer[1 * H * W + y * W + x] = pixel.g / 255.0;
        buffer[2 * H * W + y * W + x] = pixel.b / 255.0;
      }
    }
  } else {
    // ── NHWC: index = y*W*C + x*C + c ─────────────────────────────────
    for (int y = 0; y < H; y++) {
      for (int x = 0; x < W; x++) {
        final pixel = padded.getPixel(x, y);
        final int base = (y * W + x) * C;
        buffer[base + 0] = pixel.r / 255.0;
        buffer[base + 1] = pixel.g / 255.0;
        buffer[base + 2] = pixel.b / 255.0;
      }
    }
  }

  return _PreprocessResult(
    float32Buffer: buffer,
    dx: dx,
    dy: dy,
    ratio: ratio,
    imgW: original.width,
    imgH: original.height,
  );
}

// ─── NMS ─────────────────────────────────────────────────────────────────
class _NmsPayload {
  final List<List<double>> boxes; // [left, top, right, bottom, conf, classIdx]
  final double iouThreshold;
  const _NmsPayload(this.boxes, this.iouThreshold);
}

/// Non-Maximum Suppression. Input must be sorted by confidence descending.
/// Returns kept indices.
List<int> _nmsIsolate(_NmsPayload payload) {
  final boxes = payload.boxes;
  final double iou = payload.iouThreshold;
  final List<int> kept = [];

  for (int i = 0; i < boxes.length; i++) {
    bool suppress = false;
    for (final kIdx in kept) {
      final a = boxes[i];
      final b = boxes[kIdx];
      final iLeft = math.max(a[0], b[0]);
      final iTop = math.max(a[1], b[1]);
      final iRight = math.min(a[2], b[2]);
      final iBottom = math.min(a[3], b[3]);

      if (iRight > iLeft && iBottom > iTop) {
        final inter = (iRight - iLeft) * (iBottom - iTop);
        final union =
            (a[2] - a[0]) * (a[3] - a[1]) +
            (b[2] - b[0]) * (b[3] - b[1]) -
            inter;
        if (inter / union > iou) {
          suppress = true;
          break;
        }
      }
    }
    if (!suppress) kept.add(i);
  }
  return kept;
}

// ─────────────────────────────────────────────────────────────────────────
// TfliteService
// ─────────────────────────────────────────────────────────────────────────

/// Singleton service that wraps the YOLOv11 TFLite mosquito-detection
/// model.
///
/// Call [init] once at startup. Then call [predict] for each image.
///
/// ### Threading model
/// - Letterboxing + float32 normalization → background [Isolate] (CPU-bound)
/// - TFLite `run()` → called on the platform thread (fast native)
/// - NMS post-processing → background [Isolate] for >30 candidates
///
/// ### float32-only
/// This service targets the float32 YOLOv11 TFLite export exclusively —
/// all INT8/UINT8 quantization handling has been removed. Input and output
/// tensors are both assumed FLOAT32. If a differently-exported model is
/// ever loaded, `init()` will log a warning (see below) rather than silently
/// misreading the tensor buffer.
class TfliteService {
  static final TfliteService _instance = TfliteService._internal();
  factory TfliteService() => _instance;
  TfliteService._internal();

  late Interpreter _interpreter;
  late List<String> _labels;
  bool _initialized = false;

  // ── Output tensor layout ──────────────────────────────────────────────
  late bool
  _outputAnchorMajor; // true → [1, anchors, ch]; false → [1, ch, anchors]
  late int _numAnchors;
  late int _numChannels;

  // ── Input tensor metadata (discovered at init time) ───────────────────
  /// True when the model input is NCHW [1, 3, 640, 640].
  /// False when NHWC [1, 640, 640, 3].
  late bool _isNchw;

  static const int _inputSize = AppConstants.modelInputSize;
  static const int _maxDetections = 3;

  // ─── init() ─────────────────────────────────────────────────────────────
  /// Loads the TFLite model. Throws if the asset is missing.
  ///
  /// 1. Loads `Model/yolo.tflite`.
  /// 2. Calls `allocateTensors()` once, with the model's native shape (no
  ///    resize) — allocating a second time at run() time is what corrupts
  ///    internal constant tensors, so [predict] must always feed a buffer
  ///    whose shape matches exactly, never triggering an implicit resize.
  /// 3. Reads input tensor shape → detects NCHW vs NHWC layout.
  /// 4. Verifies the input/output tensors are actually FLOAT32 (logs a
  ///    warning if not — this build no longer supports quantized I/O).
  /// 5. Loads labels and detects output layout (anchor-major vs
  ///    channel-major).
  Future<void> init() async {
    if (_initialized) return;

    // ── 1. Load model ──────────────────────────────────────────────────
    final data = await rootBundle.load(AppConstants.modelPath);
    final modelBytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    debugPrint('TfliteService: loaded best.tflite');

    _interpreter = Interpreter.fromBuffer(modelBytes);

    // ── 2. allocateTensors with the model's native shape (NO resize) ────
    _interpreter.allocateTensors();

    // ── 3. Detect input layout ───────────────────────────────────────────
    final inTensor = _interpreter.getInputTensors().first;
    final List<int> inShape =
        inTensor.shape; // e.g. [1, 3, 640, 640] or [1, 640, 640, 3]

    // If dim[1] == 3 the model is NCHW (channels-first).
    // If dim[3] == 3 the model is NHWC (channels-last).
    _isNchw = (inShape.length == 4 && inShape[1] == 3);

    debugPrint(
      'TfliteService [INPUT] shape=$inShape, type=${inTensor.type}, '
      'layout=${_isNchw ? "NCHW" : "NHWC"}',
    );

    // This build assumes float32 I/O end-to-end. If a quantized model
    // somehow gets loaded, fail loudly rather than silently feeding the
    // wrong buffer type into the interpreter.
    if (inTensor.type != TensorType.float32) {
      debugPrint(
        'TfliteService WARNING: expected input tensor type float32 but '
        'found ${inTensor.type}. This build only supports the float32 '
        'export — re-export the model as float32 or restore quantization '
        'handling.',
      );
    }

    final outTensor = _interpreter.getOutputTensors().first;
    if (outTensor.type != TensorType.float32) {
      debugPrint(
        'TfliteService WARNING: expected output tensor type float32 but '
        'found ${outTensor.type}.',
      );
    }

    debugPrint(
      'TfliteService [OUTPUT] shape=${outTensor.shape}, type=${outTensor.type}',
    );

    // ── 4. Load labels ────────────────────────────────────────────────
    try {
      final raw = await rootBundle.loadString('Model/labels_classifier.txt');
      _labels = raw
          .split(RegExp(r'[\r\n]+'))
          .where((l) => l.trim().isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('TfliteService: labels not found: $e');
      _labels = <String>[];
    }

    // ── 5. Detect output layout ──────────────────────────────────────────
    final outShape = outTensor.shape;
    if (outShape.length >= 3) {
      _outputAnchorMajor = outShape[1] > outShape[2];
      _numAnchors = _outputAnchorMajor ? outShape[1] : outShape[2];
      _numChannels = _outputAnchorMajor ? outShape[2] : outShape[1];
    } else {
      _outputAnchorMajor = false;
      _numAnchors = 8400;
      _numChannels = 4 + _labels.length;
    }

    _initialized = true;

    debugPrint(
      'TfliteService: init complete — isNchw=$_isNchw, '
      'anchors=$_numAnchors, channels=$_numChannels, '
      'anchorMajor=$_outputAnchorMajor',
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────
  /// Reads one raw output value. No dequantization — the output tensor is
  /// float32, so the raw value IS the real value.
  double _readOutput(List<dynamic> output, int channel, int anchor) {
    final num raw = _outputAnchorMajor
        ? (output[0][anchor][channel] as num)
        : (output[0][channel][anchor] as num);
    return raw.toDouble();
  }

  /// CONFIRMED via anchor dump (see chat): background anchors read exactly
  /// 0.0000 on every class channel — that's what "0% probability" looks
  /// like, not what a raw logit reading "no object" looks like (that would
  /// be a large negative number, e.g. -6 to -10, never exactly zero). This
  /// float32 export already applies sigmoid to class scores inside the
  /// graph (Ultralytics' Detect head calls `cls.sigmoid()` before export).
  ///
  /// Applying sigmoid again here turned every legitimate 0.0 background
  /// reading into sigmoid(0.0) = 0.5, pushing all 8400 anchors above the
  /// confidence threshold and producing phantom multi-class detections on
  /// top of a single real object. Do NOT sigmoid these values — pass them
  /// through as-is (with a defensive clamp in case of float noise).
  double _ensureProbability(double v) => v.clamp(0.0, 1.0);

  double _toInputPixels(double value, int targetSize) {
    if (value > 0 && value <= 1.0) return value * targetSize;
    return value;
  }

  // ─── predict() ─────────────────────────────────────────────────────────
  /// Runs YOLOv11 inference on [imageFile].
  ///
  /// Pipeline:
  /// 1. Letterbox + normalize to float32 [0, 1] → background [Isolate]
  /// 2. Reshape flat buffer to the model's native 4-D input shape
  /// 3. `Interpreter.run()` → platform thread (fast native call)
  /// 4. Decode YOLO boxes → main thread
  /// 5. NMS → background [Isolate] (when >30 candidates)
  Future<PredictionResult> predict(File imageFile) async {
    assert(_initialized, 'Call TfliteService.init() before predict()');

    // ── Step 1: Background preprocessing ─────────────────────────────────
    final bytes = await imageFile.readAsBytes();

    // Capture primitives into locals so the closure is safe to send across
    // isolate boundaries (avoids capturing `this`).
    final bool capturedIsNchw = _isNchw;

    final prep = await Isolate.run(
      () => _preprocessIsolate(
        _PreprocessPayload(
          imageBytes: bytes,
          targetSize: _inputSize,
          isNchw: capturedIsNchw,
        ),
      ),
    );

    // ── Step 2: Reshape flat buffer → model's native 4-D input shape ─────
    final inputTensor = _interpreter.getInputTensors().first;
    final List<int> inputShape = inputTensor.shape; // e.g. [1, 3, 640, 640]

    final dynamic inputData = prep.float32Buffer.toList().reshape<double>(
      inputShape,
    );

    // ── Step 3: Inference ─────────────────────────────────────────────────
    final int numChannels = _numChannels;
    final int numAnchors = _numAnchors;

    // The Dart output buffer's shape must match the tensor's real shape
    // exactly, or Interpreter.run() throws. _outputAnchorMajor tells us
    // which of the two dimensions comes first in the actual tensor:
    //   anchor-major → [1, numAnchors, numChannels]
    //   channel-major → [1, numChannels, numAnchors]
    final List<List<List<double>>> output = _outputAnchorMajor
        ? List.generate(
            1,
            (_) => List.generate(
              numAnchors,
              (_) => List<double>.filled(numChannels, 0.0),
            ),
          )
        : List.generate(
            1,
            (_) => List.generate(
              numChannels,
              (_) => List<double>.filled(numAnchors, 0.0),
            ),
          );

    final sw = Stopwatch()..start();
    try {
      _interpreter.run(inputData, output);
    } catch (e, st) {
      debugPrint('TfliteService: inference failed: $e\n$st');
      throw Exception('TFLite inference failed: $e');
    } finally {
      sw.stop();
      debugPrint('>>> INFERENCE LATENCY: ${sw.elapsedMilliseconds} ms');
    }

    // ── Step 4: Decode YOLO output boxes ──────────────────────────────────
    // YOLO11 removed the separate objectness channel that legacy YOLOv5
    // models used. The output is strictly [cx, cy, w, h, cls0, cls1, ...].
    // YOLO11 with N classes → numChannels = 4 + N
    // Legacy YOLOv5 with N classes → numChannels = 4 + 1 (obj) + N = 5 + N
    // Detect legacy format only if channel count is exactly 5 + numLabels.
    final int numLabelClasses = _labels.length;
    final bool hasObjectness =
        numLabelClasses > 0 && numChannels == 5 + numLabelClasses;
    final int classOffset = hasObjectness ? 5 : 4;
    final int yoloClasses = numChannels - classOffset;
    const double confidenceThreshold = 0.45;

    // ── Raw output diagnostic (first 5 anchors) ────────────────────────
    // Remove or comment this block after confirming scores look correct.
    debugPrint(
      'TfliteService [DECODE] '
      'numChannels=$numChannels, numAnchors=$numAnchors, '
      'hasObjectness=$hasObjectness, classOffset=$classOffset, '
      'yoloClasses=$yoloClasses',
    );
    for (int dbgA = 0; dbgA < math.min(5, numAnchors); dbgA++) {
      final rawVals = List.generate(
        numChannels,
        (c) => _readOutput(output, c, dbgA).toStringAsFixed(4),
      );
      debugPrint('TfliteService [anchor $dbgA raw]: $rawVals');
    }

    final double imgW = prep.imgW.toDouble();
    final double imgH = prep.imgH.toDouble();

    final List<List<double>> rawBoxes = [];

    for (int anchor = 0; anchor < numAnchors; anchor++) {
      final double objectness = hasObjectness
          ? _ensureProbability(_readOutput(output, 4, anchor))
          : 1.0;

      double maxScore = -1.0;
      int bestClass = 0;
      for (int cls = 0; cls < yoloClasses; cls++) {
        final double score = _ensureProbability(
          _readOutput(output, classOffset + cls, anchor),
        );
        final double combined = objectness * score;
        if (combined > maxScore) {
          maxScore = combined;
          bestClass = cls;
        }
      }

      if (maxScore > confidenceThreshold) {
        final double cx = _toInputPixels(
          _readOutput(output, 0, anchor),
          _inputSize,
        );
        final double cy = _toInputPixels(
          _readOutput(output, 1, anchor),
          _inputSize,
        );
        final double w = _toInputPixels(
          _readOutput(output, 2, anchor),
          _inputSize,
        );
        final double h = _toInputPixels(
          _readOutput(output, 3, anchor),
          _inputSize,
        );

        final double origCx = (cx - prep.dx) / prep.ratio;
        final double origCy = (cy - prep.dy) / prep.ratio;
        final double origW = w / prep.ratio;
        final double origH = h / prep.ratio;

        rawBoxes.add([
          (origCx - origW / 2).clamp(0.0, imgW), // left
          (origCy - origH / 2).clamp(0.0, imgH), // top
          (origCx + origW / 2).clamp(0.0, imgW), // right
          (origCy + origH / 2).clamp(0.0, imgH), // bottom
          maxScore,
          bestClass.toDouble(),
        ]);
      }
    }

    debugPrint('TfliteService: ${rawBoxes.length} candidates before NMS');

    // ── Step 5: Per-class NMS ─────────────────────────────────────────────
    rawBoxes.sort((a, b) => b[4].compareTo(a[4])); // sort by confidence desc

    const double nmsIouThreshold = 0.35;
    final List<int> keptIndices = [];

    // Group raw-box indices by class.
    final Map<int, List<int>> classGroups = {};
    for (int i = 0; i < rawBoxes.length; i++) {
      final int cls = rawBoxes[i][5].toInt();
      classGroups.putIfAbsent(cls, () => []).add(i);
    }

    // Run NMS independently for each class, then merge.
    for (final entry in classGroups.entries) {
      final List<int> groupGlobalIdx = entry.value;
      final List<List<double>> groupBoxes = groupGlobalIdx
          .map((gi) => rawBoxes[gi])
          .toList();
      final List<int> keptLocal = groupBoxes.length > 30
          ? await Isolate.run(
              () => _nmsIsolate(_NmsPayload(groupBoxes, nmsIouThreshold)),
            )
          : _nmsIsolate(_NmsPayload(groupBoxes, nmsIouThreshold));
      keptIndices.addAll(keptLocal.map((k) => groupGlobalIdx[k]));
    }

    // Re-sort merged survivors by confidence descending.
    keptIndices.sort((a, b) => rawBoxes[b][4].compareTo(rawBoxes[a][4]));

    // ── Step 6: Build final detections ────────────────────────────────────
    final List<Detection> finalDetections = [];
    for (final idx in keptIndices) {
      if (finalDetections.length >= _maxDetections) break;

      final box = rawBoxes[idx];
      final int clsIdx = box[5].toInt();
      final String label = clsIdx < _labels.length
          ? _labels[clsIdx]
          : 'Unknown';
      if (label.toLowerCase() == 'non-mosquito') continue;

      finalDetections.add(
        Detection(
          label: label,
          confidence: box[4],
          boundingBox: Rect.fromLTRB(box[0], box[1], box[2], box[3]),
        ),
      );
    }

    debugPrint('TfliteService: ${finalDetections.length} final detections');

    return PredictionResult(
      detections: finalDetections,
      imageSize: Size(imgW, imgH),
    );
  }

  List<String> get labels => List.unmodifiable(_labels);
  bool get isInitialized => _initialized;
}
