import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/prediction_result.dart';

// ─────────────────────────────────────────────────────────────────────────
// Top-level helpers — must be top-level so they cross isolate boundaries.
// ─────────────────────────────────────────────────────────────────────────

/// Payload sent to the background preprocessing isolate.
///
/// This service targets the SSD MobileNet V2 TFLite export trained via the
/// TF2 Object Detection API (see pipeline.config).
///
/// PREPROCESSING — pipeline.config uses `fixed_shape_resizer` (300x300), a
/// direct stretch-resize, NOT the aspect-ratio-preserving letterbox with
/// grey padding that YOLO used. No dx/dy/ratio compensation is needed when
/// mapping boxes back to the original image: a normalized box coordinate
/// maps straight to the same fractional position in the original image.
///
/// NORMALIZATION — this assumes the standard `export_tflite_graph_tf2.py`
/// export path, where SSD MobileNetV2's preprocessing
/// ((2/255)*pixel - 1 -> range [-1,1]) is baked into the TFLite graph
/// itself. That means the app feeds RAW pixel values [0, 255] as float32 —
/// it does NOT pre-divide by 255. *** VERIFY THIS *** if detections look
/// wrong: try `pixel / 127.5 - 1.0` instead, done in this isolate.
class _PreprocessPayload {
  final Uint8List imageBytes;
  final int targetWidth;
  final int targetHeight;

  const _PreprocessPayload({
    required this.imageBytes,
    required this.targetWidth,
    required this.targetHeight,
  });
}

/// Result returned from the preprocessing isolate.
class _PreprocessResult {
  /// Flat FLOAT32 tensor buffer, NHWC layout, RAW pixel values [0, 255].
  final Float32List float32Buffer;

  final int imgW;
  final int imgH;

  const _PreprocessResult({
    required this.float32Buffer,
    required this.imgW,
    required this.imgH,
  });
}

/// Direct resize (no aspect-ratio preservation, no padding) to match
/// `fixed_shape_resizer` from pipeline.config. Runs in a background isolate.
_PreprocessResult _preprocessIsolate(_PreprocessPayload payload) {
  img.Image? original = img.decodeImage(payload.imageBytes);
  if (original == null) throw Exception('Could not decode image');
  original = img.bakeOrientation(original);

  final int imgW = original.width;
  final int imgH = original.height;

  final resized = img.copyResize(
    original,
    width: payload.targetWidth,
    height: payload.targetHeight,
    interpolation: img.Interpolation.linear,
  );

  final int W = payload.targetWidth;
  final int H = payload.targetHeight;
  const int C = 3;

  final Float32List buffer = Float32List(1 * H * W * C);

  for (int y = 0; y < H; y++) {
    for (int x = 0; x < W; x++) {
      final pixel = resized.getPixel(x, y);
      final int base = (y * W + x) * C;
      buffer[base + 0] = pixel.r.toDouble();
      buffer[base + 1] = pixel.g.toDouble();
      buffer[base + 2] = pixel.b.toDouble();
    }
  }

  return _PreprocessResult(float32Buffer: buffer, imgW: imgW, imgH: imgH);
}

// ─────────────────────────────────────────────────────────────────────────
// TfliteService
// ─────────────────────────────────────────────────────────────────────────

/// Singleton service that wraps the SSD MobileNet V2 TFLite mosquito-
/// detection model. Replaces the previous YOLOv11 service in place — same
/// public surface (init / predict / labels / isInitialized).
///
/// ### Output tensor identification (auto-detected, not hardcoded)
/// A real device run showed the 4 output tensors do NOT sit at the indices
/// the standard TFLite_Detection_PostProcess docs imply (boxes was not at
/// index 0). Rather than hardcode indices again, this service identifies
/// tensors by shape at init():
///   - rank 3, last dim 4        -> boxes
///   - total element count == 1  -> num_detections
///   - the remaining two [1, N] tensors -> classes / scores, disambiguated
///     at runtime on first predict() call by checking which one's values
///     are bounded in [0,1] (scores, since pipeline.config uses
///     score_converter: SIGMOID) vs. class-index-like values.
/// This also means output buffers are sized to whatever N the model
/// actually reports (see _maxRawDetections), not a hardcoded guess.
class TfliteService {
  static final TfliteService _instance = TfliteService._internal();
  factory TfliteService() => _instance;
  TfliteService._internal();

  late Interpreter _interpreter;
  late List<String> _labels;
  bool _initialized = false;

  // From pipeline.config's fixed_shape_resizer.
  static const int _inputWidth = 300;
  static const int _inputHeight = 300;

  static const int _maxDetectionsToShow = 3;

  // The graph's own NMS uses score_threshold≈1e-8 (effectively unfiltered)
  // — the app still needs its own confidence cutoff. Carried over from the
  // YOLO service as a starting point; re-tune against real SSD output.
  static const double _confidenceThreshold = 0.45;

  static const String _modelAssetPath = 'Model/ssd_mobilenet.tflite';

  // ── Output tensor layout (discovered at init) ──────────────────────────
  late int _boxesOutputIdx;
  late int _numDetOutputIdx;
  late List<int> _classScoreCandidateIdx; // exactly 2 indices, order TBD
  int? _classesOutputIdx; // resolved on first predict()
  int? _scoresOutputIdx;
  late int _maxRawDetections; // N from boxes tensor shape [1, N, 4]

  Future<void> init() async {
    if (_initialized) return;

    final data = await rootBundle.load(_modelAssetPath);
    final modelBytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    debugPrint('TfliteService: loaded $_modelAssetPath');

    _interpreter = Interpreter.fromBuffer(modelBytes);
    _interpreter.allocateTensors();

    final inTensor = _interpreter.getInputTensors().first;
    debugPrint(
      'TfliteService [INPUT] shape=${inTensor.shape}, type=${inTensor.type}',
    );
    if (inTensor.type != TensorType.float32) {
      debugPrint(
        'TfliteService WARNING: expected input tensor type float32 but '
        'found ${inTensor.type}.',
      );
    }

    // ── Identify output tensors by shape, not by index ───────────────────
    final outTensors = _interpreter.getOutputTensors();
    debugPrint('TfliteService: ${outTensors.length} output tensors:');
    for (int i = 0; i < outTensors.length; i++) {
      debugPrint(
        '  [$i] ${outTensors[i].name}: shape=${outTensors[i].shape}, type=${outTensors[i].type}',
      );
    }

    int? boxesIdx;
    int? numDetIdx;
    final List<int> remaining = [];

    for (int i = 0; i < outTensors.length; i++) {
      final shape = outTensors[i].shape;
      final int totalSize = shape.fold(1, (a, b) => a * b);
      if (shape.length == 3 && shape.last == 4) {
        boxesIdx = i;
      } else if (totalSize == 1) {
        numDetIdx = i;
      } else {
        remaining.add(i);
      }
    }

    if (boxesIdx == null || numDetIdx == null || remaining.length != 2) {
      debugPrint(
        'TfliteService WARNING: could not confidently identify output '
        'tensors by shape (boxes=$boxesIdx, numDetections=$numDetIdx, '
        'remaining=$remaining). Expected exactly one [1,N,4] boxes tensor, '
        'one scalar num_detections tensor, and two [1,N] tensors '
        '(classes + scores). This model\'s output does not match the '
        'standard TFLite_Detection_PostProcess format — decode will '
        'likely throw. Send me this log line.',
      );
    }

    _boxesOutputIdx = boxesIdx!;
    _numDetOutputIdx = numDetIdx!;
    _classScoreCandidateIdx = remaining;
    _maxRawDetections = outTensors[boxesIdx].shape[1];

    debugPrint(
      'TfliteService: output layout — boxes=idx$_boxesOutputIdx, '
      'numDetections=idx$_numDetOutputIdx, '
      'classes/scores candidates=$_classScoreCandidateIdx '
      '(resolved on first predict), maxRawDetections=$_maxRawDetections',
    );

    // *** MUST VERIFY ***: order must match MosquitoType_label_map.pbtxt's
    // id-ascending order. Detection class output is 0-indexed and maps
    // directly to this list by position.
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

    _initialized = true;
    debugPrint('TfliteService: init complete — labels=$_labels');
  }

  Future<PredictionResult> predict(File imageFile) async {
    assert(_initialized, 'Call TfliteService.init() before predict()');

    final bytes = await imageFile.readAsBytes();

    final prep = await Isolate.run(
      () => _preprocessIsolate(
        _PreprocessPayload(
          imageBytes: bytes,
          targetWidth: _inputWidth,
          targetHeight: _inputHeight,
        ),
      ),
    );

    final inputTensor = _interpreter.getInputTensors().first;
    final List<int> inputShape = inputTensor.shape; // e.g. [1, 300, 300, 3]
    final dynamic inputData = prep.float32Buffer.toList().reshape<double>(
      inputShape,
    );

    // Buffers sized to _maxRawDetections (discovered at init), not a
    // hardcoded guess — this is what fixes the shape-mismatch crash.
    final List<List<List<double>>> outBoxes = List.generate(
      1,
      (_) =>
          List.generate(_maxRawDetections, (_) => List<double>.filled(4, 0.0)),
    );
    final List<List<double>> outA = List.generate(
      1,
      (_) => List<double>.filled(_maxRawDetections, 0.0),
    );
    final List<List<double>> outB = List.generate(
      1,
      (_) => List<double>.filled(_maxRawDetections, 0.0),
    );
    final List<double> outNumDetections = List<double>.filled(1, 0.0);

    final Map<int, Object> outputs = <int, Object>{
      _boxesOutputIdx: outBoxes,
      _classScoreCandidateIdx[0]: outA,
      _classScoreCandidateIdx[1]: outB,
      // NOT wrapped in an extra list — the real tensor is rank 1, shape
      // [1], not [1, 1]. (Fixed after a real device run showed this exact
      // shape mismatch.)
      _numDetOutputIdx: outNumDetections,
    };

    try {
      _interpreter.runForMultipleInputs(<Object>[inputData], outputs);
    } catch (e, st) {
      debugPrint('TfliteService: inference failed: $e\n$st');
      throw Exception('TFLite inference failed: $e');
    }

    // ── Resolve classes vs scores once, on first successful inference ────
    if (_classesOutputIdx == null || _scoresOutputIdx == null) {
      bool boundedZeroToOne(List<double> vals) =>
          vals.every((v) => v >= 0.0 && v <= 1.0);

      final bool aLooksLikeScores = boundedZeroToOne(outA[0]);
      final bool bLooksLikeScores = boundedZeroToOne(outB[0]);

      if (aLooksLikeScores && !bLooksLikeScores) {
        _scoresOutputIdx = _classScoreCandidateIdx[0];
        _classesOutputIdx = _classScoreCandidateIdx[1];
      } else if (bLooksLikeScores && !aLooksLikeScores) {
        _scoresOutputIdx = _classScoreCandidateIdx[1];
        _classesOutputIdx = _classScoreCandidateIdx[0];
      } else {
        // Ambiguous (e.g. a no-detection test image where both read all
        // zero) — default to candidate order and warn loudly. VERIFY
        // against an image with a real, known-species detection.
        _classesOutputIdx = _classScoreCandidateIdx[0];
        _scoresOutputIdx = _classScoreCandidateIdx[1];
        debugPrint(
          'TfliteService WARNING: could not confidently distinguish '
          'classes from scores (both bounded in [0,1], or neither was) — '
          'defaulting to idx${_classesOutputIdx}=classes, '
          'idx${_scoresOutputIdx}=scores. VERIFY this against a real '
          'detection with a known species before trusting labels.',
        );
      }
      debugPrint(
        'TfliteService: resolved classes=idx$_classesOutputIdx, '
        'scores=idx$_scoresOutputIdx',
      );
    }

    final List<double> classesRaw =
        (_classesOutputIdx == _classScoreCandidateIdx[0]) ? outA[0] : outB[0];
    final List<double> scoresRaw =
        (_scoresOutputIdx == _classScoreCandidateIdx[0]) ? outA[0] : outB[0];

    final double imgW = prep.imgW.toDouble();
    final double imgH = prep.imgH.toDouble();

    final int numDetections = outNumDetections[0].round().clamp(
      0,
      _maxRawDetections,
    );

    debugPrint(
      'TfliteService [DECODE] numDetections=$numDetections, '
      'top score=${numDetections > 0 ? scoresRaw[0] : 0.0}',
    );

    // [left, top, right, bottom, conf, classIdx]
    final List<List<double>> candidates = [];

    for (int i = 0; i < numDetections; i++) {
      final double score = scoresRaw[i];
      final int classIdx = classesRaw[i].round();

      // No letterbox compensation needed — direct resize means normalized
      // box coords map straight to fractional position in the original
      // image (see class doc comment).
      final double ymin = outBoxes[0][i][0];
      final double xmin = outBoxes[0][i][1];
      final double ymax = outBoxes[0][i][2];
      final double xmax = outBoxes[0][i][3];

      // Logged for EVERY raw candidate, before the confidence filter below
      // — if these normalized coords are already tiny/near-zero here, the
      // degenerate box is coming from the model itself, not from anything
      // downstream in this file.
      debugPrint(
        'TfliteService [RAW $i] class=$classIdx score=${score.toStringAsFixed(4)} '
        'ymin=${ymin.toStringAsFixed(4)} xmin=${xmin.toStringAsFixed(4)} '
        'ymax=${ymax.toStringAsFixed(4)} xmax=${xmax.toStringAsFixed(4)}',
      );

      if (score < _confidenceThreshold) continue;

      candidates.add([
        (xmin * imgW).clamp(0.0, imgW),
        (ymin * imgH).clamp(0.0, imgH),
        (xmax * imgW).clamp(0.0, imgW),
        (ymax * imgH).clamp(0.0, imgH),
        score,
        classIdx.toDouble(),
      ]);
    }

    // Graph already applied NMS — no app-side NMS pass needed.
    candidates.sort((a, b) => b[4].compareTo(a[4]));

    final List<Detection> finalDetections = [];
    for (final box in candidates) {
      if (finalDetections.length >= _maxDetectionsToShow) break;
      final int clsIdx = box[5].toInt();
      final String label = clsIdx < _labels.length
          ? _labels[clsIdx]
          : 'Unknown';
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
