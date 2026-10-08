import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:DengueLens/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import '../models/prediction_result.dart';
import '../models/scan_record.dart';
import '../services/connectivity_service.dart';
import '../services/history_service.dart';
import '../services/location_service.dart';
import '../services/sighting_upload_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'symptom_questionnaire_screen.dart';

class ResultScreen extends StatefulWidget {
  final String result; // "positive" or "negative"
  final double confidence; // 0.0 to 1.0
  final String sampleType; // e.g., "Blood Sample"
  final String mosquitoType; // e.g., "Aedes aegypti"
  final DateTime testDate;
  final File? imagePath; // User uploaded image
  final Rect? boundingBox;
  final List<Detection>? detections;
  final Size? imageSize;
  final int? savedDetectionCount;

  /// Prefetched GPS position at capture time.
  final Position? capturedPosition;

  /// When true, the "Record Result" button is hidden (opened from history).
  final bool isFromHistory;

  const ResultScreen({
    super.key,
    this.result = "negative",
    this.confidence = 0.0,
    this.sampleType = "Mosquito Photo",
    required this.mosquitoType,
    required this.testDate,
    this.imagePath,
    this.boundingBox,
    this.detections,
    this.imageSize,
    this.savedDetectionCount,
    this.capturedPosition,
    this.isFromHistory = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  static const Color _blue = Color(0xFF3498DB);
  Uint8List? _displayBytes;

  // Duplicate-prevention & loading flags
  bool _isRecorded = false;
  bool _isShared = false;
  bool _isRecording = false;
  bool _isSharing = false;

  // Current saved scan count (read from HistoryService)
  int _savedScanCount = 0;
  static const int _maxScans = 12;

  // Prefetched GPS position at screen entry/capture time
  Position? _capturedPosition;

  String _normalizedDetectionLabel(String rawType) {
    final lower = rawType.toLowerCase();
    if (lower.contains('aegypti')) return 'aegypti';
    if (lower.contains('albopictus')) return 'albopictus';
    if (lower.contains('culex')) return 'culex';
    if (lower.contains('anopheles')) return 'anopheles';
    if (lower.contains('non-mosquito')) return 'non-mosquito';
    return rawType;
  }

  List<Detection> get _overlayDetections {
    if (widget.detections != null && widget.detections!.isNotEmpty) {
      return widget.detections!;
    }
    if (widget.mosquitoType.isNotEmpty) {
      final label = _normalizedDetectionLabel(widget.mosquitoType);
      if (label != 'unknown' &&
          !label.toLowerCase().contains('no mosquito') &&
          label != 'none' &&
          label != 'non-mosquito') {
        return [
          Detection(
            label: label,
            confidence: widget.confidence,
            boundingBox: widget.boundingBox ?? Rect.zero,
          ),
        ];
      }
    }
    return const [];
  }

  /// True if any of the detections is a dengue vector.
  bool get _hasAnyDengueVector =>
      _overlayDetections.any((d) => d.isDengueVector);

  Future<void> _prepareDisplayImage() async {
    if (widget.imagePath == null) return;
    try {
      final bytes = await widget.imagePath!.readAsBytes();
      // Offload the CPU-intensive decode + EXIF-bake to a background isolate
      // so the result screen's animations and scrolling remain fluid.
      final oriented = await Isolate.run(() {
        final decoded = img.decodeImage(bytes);
        if (decoded == null) return null;
        return Uint8List.fromList(
          img.encodeJpg(img.bakeOrientation(decoded), quality: 90),
        );
      });
      if (!mounted || oriented == null) return;
      setState(() => _displayBytes = oriented);
    } catch (_) {
      // Fall back to Image.file if decoding fails
    }
  }

  /// Saves the scan result to local history (Hive) only.
  void _recordResult() async {
    if (_isRecorded || _isRecording) return;
    setState(() => _isRecording = true);

    try {
      final normalized = widget.result.toLowerCase();
      final isPositive = normalized == 'positive';

      // 1. Get GPS for the local record (prefer captured position at scan time)
      final pos = _capturedPosition ?? await LocationService().getCurrentPosition();
      final locString = pos != null
          ? LocationService().toLocationString(pos)
          : null;

      // Persist the scan image to app documents directory so cache cleaners cannot remove it
      File? persistentImageFile = widget.imagePath;
      if (widget.imagePath != null && widget.imagePath!.existsSync()) {
        try {
          final docDir = await getApplicationDocumentsDirectory();
          final scansDir = Directory('${docDir.path}/scans');
          if (!scansDir.existsSync()) {
            await scansDir.create(recursive: true);
          }
          final targetPath = '${scansDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          persistentImageFile = await widget.imagePath!.copy(targetPath);
        } catch (_) {
          persistentImageFile = widget.imagePath;
        }
      }

      // 2. Save locally only
      await HistoryService().addRecord(
        ScanRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          mosquitoType: widget.mosquitoType,
          result: isPositive ? 'Dengue vector' : 'Not a dengue vector',
          confidence: widget.confidence,
          date: widget.testDate,
          imageFile: persistentImageFile,
          location: locString,
          detectionCount:
              widget.savedDetectionCount ?? (widget.detections?.length ?? 1),
          detections: widget.detections,
          imageWidth: widget.imageSize?.width,
          imageHeight: widget.imageSize?.height,
        ),
      );

      if (mounted) {
        setState(() => _isRecorded = true);
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.resultSavedToHistory),
            backgroundColor: const Color(0xFF2ECC71),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRecording = false);
    }
  }

  /// Uploads the dengue vector sighting to Firestore (shared on the map).
  void _shareResult() async {
    if (_isShared || _isSharing) return;
    setState(() => _isSharing = true);

    try {
      // 1. Check internet connectivity
      final hasInternet = await ConnectivityService().hasInternetAccess();
      if (!hasInternet) {
        if (mounted) _showNoInternetDialog();
        return;
      }

      // 2. Get GPS (prefer captured position at scan time)
      final pos = _capturedPosition ?? await LocationService().getCurrentPosition();
      if (pos == null) {
        if (mounted) {
          final loc = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.unableToGetLocation),
              backgroundColor: const Color(0xFFE74C3C),
            ),
          );
        }
        return;
      }

      // 3. Upload to Firestore
      // Derive species from the actual detection list, not just the display string,
      // to avoid defaulting non-dengue species (Culex/Anopheles) to 'albopictus'.
      final dengueVectors = _overlayDetections
          .where((d) => d.isDengueVector)
          .toList();
      if (dengueVectors.isEmpty) {
        // Nothing to share – not a dengue vector
        if (mounted) setState(() => _isSharing = false);
        return;
      }
      dengueVectors.sort((a, b) => b.confidence.compareTo(a.confidence));
      final species = dengueVectors.first.label
          .toLowerCase(); // 'aegypti' | 'albopictus'
      await SightingUploadService().upload(
        species: species,
        lat: pos.latitude,
        lng: pos.longitude,
        confidence: widget.confidence,
        timestamp: widget.testDate,
      );

      if (mounted) {
        setState(() => _isShared = true);
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.sightingSharedToMap),
            backgroundColor: const Color(0xFF2ECC71),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  /// Shows a dialog informing the user there is no internet connection.
  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  loc.noInternetConnection,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            loc.noInternetDesc,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                loc.ok,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _capturedPosition = widget.capturedPosition;
    _prepareDisplayImage();
    if (_capturedPosition == null) {
      _fetchCaptureLocation();
    }
    // Read current saved scan count from HistoryService
    _savedScanCount = HistoryService().records.length;
    // Show bottom sheet if any dengue carrier detected, or alert if no mosquito
    // Suppress when opened from history
    if (!widget.isFromHistory) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_hasAnyDengueVector) {
          _showBittenBottomSheet();
        } else if (_overlayDetections.isEmpty) {
          _showNoMosquitoPrompt();
        }
      });
    }
  }

  void _fetchCaptureLocation() async {
    try {
      final pos = await LocationService().getCurrentPosition();
      if (mounted) {
        setState(() => _capturedPosition = pos);
      }
    } catch (_) {}
  }

  void _showNoMosquitoPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  loc.noMosquitoDetected,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            loc.noMosquitoDetectedDesc,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                loc.ok,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageWithOverlay(Color resultColor) {
    final overlay = _overlayDetections;
    final imageSize = widget.imageSize;

    if (imageSize == null || overlay.isEmpty) {
      return Image.file(
        widget.imagePath!,
        width: double.infinity,
        fit: BoxFit.contain,
      );
    }

    return AspectRatio(
      aspectRatio: imageSize.width / imageSize.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_displayBytes != null)
            Image.memory(_displayBytes!, fit: BoxFit.cover)
          else
            Image.file(widget.imagePath!, fit: BoxFit.cover),
          CustomPaint(
            painter: DetectionOverlayPainter(
              detections: overlay,
              originalImageSize: imageSize,
              color: resultColor,
            ),
            child: const SizedBox.expand(),
          ),
        ],
      ),
    );
  }

  void _showBittenBottomSheet() {
    // Find the highest-confidence dengue vector for the bottom sheet message
    final vectors = _overlayDetections.where((d) => d.isDengueVector).toList();
    vectors.sort((a, b) => b.confidence.compareTo(a.confidence));
    final primaryVector = vectors.isNotEmpty
        ? vectors.first.displayName
        : widget.mosquitoType;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pest_control,
                    color: Colors.orange.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.wereBitten,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.bitenDesc(primaryVector),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.no,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SymptomQuestionnaireScreen(
                              mosquitoType: primaryVector,
                              skipBittenQuestion: true,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.health_and_safety, size: 18),
                      label: Text(
                        AppLocalizations.of(context)!.yesCheckSymptoms,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFFE74C3C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the overall risk banner shown at the very top of the results section.
  Widget _buildOverallBanner() {
    final loc = AppLocalizations.of(context);
    final detections = _overlayDetections;
    final hasAegypti = detections.any((d) => d.riskLevel == 'high');
    final hasAlbopictus = detections.any((d) => d.riskLevel == 'moderate');

    // Determine banner color: red = high risk, amber = moderate risk, green = not a vector / clear
    final Color color = hasAegypti
        ? const Color(0xFFC62828)
        : hasAlbopictus
        ? const Color(0xFFF57F17)
        : const Color(0xFF2E7D32);
    final IconData icon = hasAegypti
        ? Icons.warning_rounded
        : hasAlbopictus
        ? Icons.info_rounded
        : Icons.check_circle_rounded;

    // If detections list is empty but a mosquito was identified via mosquitoType
    // (e.g. Culex passed as a string), treat it as 1 detected mosquito.
    final mt = widget.mosquitoType.toLowerCase();
    final hasNamedMosquito =
        mt.isNotEmpty && mt != 'unknown' && mt != 'no mosquito' && mt != 'none';
    final count =
        widget.savedDetectionCount ??
        (detections.isNotEmpty
            ? detections.length
            : (hasNamedMosquito ? 1 : 0));
    final countLabel = count == 1
        ? (loc?.mosquitoDetected ?? '1 Mosquito Detected')
        : (loc?.mosquitoesDetected(count) ?? '$count Mosquitoes Detected');
    final riskLabel = hasAegypti
        ? (loc?.highRiskBanner ?? 'HIGH RISK — Dengue Vector Detected')
        : hasAlbopictus
        ? (loc?.moderateRiskBanner ?? 'MODERATE RISK — Dengue Vector Detected')
        : count > 0
        ? (loc?.notADengueVector ?? 'Not a Dengue Vector')
        : (loc?.noMosquitoDetected ?? 'No Mosquito Detected');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.18),
            ),
            padding: const EdgeInsets.all(20),
            child: Icon(icon, size: 60, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            riskLabel,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          if (count > 0) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                countLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds an individual detection card for a single [Detection].
  Widget _buildDetectionCard(Detection detection, int index) {
    final loc = AppLocalizations.of(context);
    final risk = detection.riskLevel; // 'high', 'moderate', or 'none'
    final Color color = risk == 'high'
        ? const Color(0xFFC62828)
        : risk == 'moderate'
        ? const Color(0xFFF57F17)
        : const Color(0xFF2E7D32);
    final String riskBadge = risk == 'high'
        ? (loc?.highRisk ?? 'HIGH RISK')
        : risk == 'moderate'
        ? (loc?.moderateRisk ?? 'MODERATE RISK')
        : (loc?.notAVector ?? 'NOT A VECTOR');
    final String subLabel = risk == 'high'
        ? (loc?.dengueVectorHighRisk ?? 'Dengue Vector — High Risk')
        : risk == 'moderate'
        ? (loc?.dengueVectorModerateRisk ?? 'Dengue Vector — Moderate Risk')
        : (loc?.notADengueVector ?? 'Not a Dengue Vector');
    final confidencePct = (detection.confidence * 100).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Colored circle with index number
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Text(
                  '#$index',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name & risk label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detection.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            // Risk + confidence badge column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    riskBadge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '$confidencePct%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the recommendation text based on all detections.
  String _buildRecommendationText() {
    final detections = _overlayDetections;
    if (detections.isEmpty) {
      return 'No mosquito was detected in this image. '
          'If you believe a mosquito is present, try taking a clearer photo. '
          'If symptoms persist, please consult a healthcare professional.';
    }
    final hasDengue = _hasAnyDengueVector;
    if (hasDengue) {
      final vectors = detections
          .where((d) => d.isDengueVector)
          .map((d) => d.displayName);
      final names = vectors.toSet().join(', ');
      return '$names ${vectors.length == 1 ? "is" : "are"} known dengue carrier${vectors.length == 1 ? "" : "s"}. '
          'If you were bitten, please check your symptoms to assess your risk level.';
    }
    final names = detections.map((d) => d.displayName).toSet().join(', ');
    return '$names ${detections.length == 1 ? "is" : "are"} not known carrier${detections.length == 1 ? "" : "s"} of the dengue virus. '
        'However, if symptoms persist, please consult with a healthcare professional.';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final detections = _overlayDetections;
    final isPositive = _hasAnyDengueVector;
    final resultColor = isPositive ? const Color(0xFFC62828) : const Color(0xFF2E7D32);
    final resultMessage = isPositive
        ? 'Dengue vector'
        : (loc?.notADengueVector ?? 'Not a dengue vector');

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ── Image with bounding-box overlay ──────────────────────────
              if (widget.imagePath != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImageWithOverlay(resultColor),
                  ),
                ),

              // ── Overall risk banner ───────────────────────────────────────
              _buildOverallBanner(),

              // ── Per-detection cards + details ─────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    if (detections.isNotEmpty) ...[
                      Text(
                        detections.length == 1
                            ? (loc?.detectionResult ?? 'Detection Result')
                            : (loc?.detectionResults(detections.length) ??
                                'Detection Results (${detections.length})'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // One card per detection
                      ...detections.asMap().entries.map(
                        (e) => _buildDetectionCard(e.value, e.key + 1),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Detection Details (dengue vector only) ───────────────
                    if (isPositive) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc?.detectionDetails ?? 'Detection Details',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              _DetailRow(
                                label: loc?.sampleType ?? 'Sample Type',
                                value: widget.sampleType,
                              ),
                              const Divider(),
                              _DetailRow(
                                label: detections.length == 1
                                    ? (loc?.mosquitoType ?? 'Mosquito Type')
                                    : (loc?.primaryMosquito ?? 'Primary Mosquito'),
                                value: widget.mosquitoType,
                              ),
                              const Divider(),
                              _DetailRow(
                                label: loc?.detectionDate ?? 'Detection Date',
                                value:
                                    '${widget.testDate.day}/${widget.testDate.month}/${widget.testDate.year}',
                              ),
                              const Divider(),
                              _DetailRow(
                                label: loc?.result ?? 'Result',
                                value: resultMessage,
                                valueColor: resultColor,
                              ),
                              const Divider(),
                              _DetailRow(
                                label: loc?.confidence ?? 'Confidence',
                                value:
                                    '${(widget.confidence * 100).toStringAsFixed(1)}%',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Recommendation Card ───────────────────────────────
                    Card(
                      color: isPositive
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isPositive
                                      ? Icons.health_and_safety
                                      : Icons.info,
                                  color: resultColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  loc?.recommendation ?? 'Recommendation',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: resultColor,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _buildRecommendationText(),
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ── Action Buttons ────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.home),
                        label: Text(loc?.backToHomeBtn ?? 'Back to Home'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF2ECC71),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!widget.isFromHistory) ...[
                      // ── Share Result (Firestore upload) — dengue vectors only ──
                      if (_hasAnyDengueVector) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: (_isShared || _isSharing)
                                ? null
                                : _shareResult,
                            icon: _isSharing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    _isShared
                                        ? Icons.check_circle
                                        : Icons.share,
                                    size: 20,
                                  ),
                            label: Text(
                              _isShared
                                  ? AppLocalizations.of(context)!.resultShared
                                  : AppLocalizations.of(context)!.shareResult,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: _isShared
                                  ? const Color(0xFF2ECC71)
                                  : const Color(0xFFE67E22),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // ── Record Result (local save only) ──

                      // Scan storage counter badge
                      if (!_isRecorded) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3498DB).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF3498DB).withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.folder_outlined,
                                size: 16,
                                color: Color(0xFF3498DB),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Scan history: $_savedScanCount / $_maxScans saved',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3498DB),
                                ),
                              ),
                              const Spacer(),
                              // Mini progress indicator
                              SizedBox(
                                width: 60,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _savedScanCount / _maxScans,
                                    backgroundColor: const Color(0xFF3498DB)
                                        .withValues(alpha: 0.15),
                                    color: _savedScanCount >= _maxScans
                                        ? const Color(0xFFF39C12)
                                        : const Color(0xFF3498DB),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // FIFO warning — only when at max capacity
                        if (_savedScanCount >= _maxScans) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFF39C12).withValues(alpha: 0.6),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFFF39C12),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'You have 12 saved scans (maximum). '  
                                    'Saving this scan will automatically delete your oldest saved scan.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      height: 1.4,
                                      color: Color(0xFF7D5A00),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (_isRecorded || _isRecording)
                              ? null
                              : _recordResult,
                          icon: _isRecording
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  _isRecorded
                                      ? Icons.check_circle
                                      : Icons.save_outlined,
                                  size: 20,
                                ),
                          label: Text(
                            _isRecorded
                                ? AppLocalizations.of(context)!.resultRecorded
                                : AppLocalizations.of(context)!.recordResult,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: _isRecorded
                                ? const Color(0xFF2ECC71)
                                : _blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class DetectionOverlayPainter extends CustomPainter {
  final List<Detection> detections;
  final Size originalImageSize;
  final Color color;

  DetectionOverlayPainter({
    required this.detections,
    required this.originalImageSize,
    required this.color,
  });

  Rect _scaleBox(Rect box, Size size) {
    final scale = size.width / originalImageSize.width;
    return Rect.fromLTRB(
      box.left * scale,
      box.top * scale,
      box.right * scale,
      box.bottom * scale,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < detections.length; i++) {
      final detection = detections[i];
      // Each detection box gets a slightly different hue: dengue = red, others = green
      final boxColor = detection.isDengueVector ? Colors.red : Colors.green;

      final stroke = Paint()
        ..color = boxColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;

      final scaledBox = _scaleBox(detection.boundingBox, size);
      if (scaledBox.width < 2 || scaledBox.height < 2) continue;

      canvas.drawRect(scaledBox, stroke);

      final label = detection.displayName;
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelTop = math.max(0.0, scaledBox.top - textPainter.height - 4);
      final labelBgRect = Rect.fromLTWH(
        scaledBox.left,
        labelTop,
        textPainter.width + 8,
        textPainter.height + 4,
      );

      canvas.drawRect(
        labelBgRect,
        Paint()
          ..color = boxColor.withValues(alpha: 0.85)
          ..style = PaintingStyle.fill,
      );

      textPainter.paint(canvas, Offset(scaledBox.left + 4, labelTop + 2));
    }
  }

  @override
  bool shouldRepaint(covariant DetectionOverlayPainter oldDelegate) =>
      oldDelegate.detections != detections ||
      oldDelegate.originalImageSize != originalImageSize;
}
