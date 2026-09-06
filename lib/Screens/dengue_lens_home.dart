import 'dart:io';
import 'package:DengueLens/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/prediction_result.dart';
import '../services/tflite_service.dart';
import '../services/tutorial_service.dart';
import 'dengue_lens_history.dart';
import 'educational_library_screen.dart';
import 'result_screen.dart';
import 'symptom_questionnaire_screen.dart';
import 'point_map_screen.dart';
import 'tutorial_overlay.dart';
import 'settings_dialog.dart';

class DengueLensHome extends StatefulWidget {
  final bool modelReady;
  const DengueLensHome({super.key, required this.modelReady});

  @override
  State<DengueLensHome> createState() => _DengueLensHomeState();
}

class _DengueLensHomeState extends State<DengueLensHome> {
  bool _isProcessing = false;
  String? _processingImagePath; // shown in loading overlay
  bool _showTutorial = false;

  // GlobalKeys for tutorial spotlight targets
  final GlobalKey _scanButtonKey = GlobalKey();
  final GlobalKey _uploadButtonKey = GlobalKey();
  final GlobalKey _navBarKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Show tutorial on first launch after the frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!TutorialService().hasSeenTutorial && mounted) {
        setState(() => _showTutorial = true);
      }
    });
  }

  /// Opens the Settings dialog (language, tutorial, exit).
  void _showSettings() {
    showDialog(
      context: context,
      builder: (ctx) => SettingsDialog(
        onReplayTutorial: () {
          if (mounted) setState(() => _showTutorial = true);
        },
      ),
    );
  }

  /// Best detection box for overlay (matches [PredictionResult.displayName] priority).
  Rect? _primaryBoundingBox(PredictionResult prediction) {
    final detections = prediction.detections;
    if (detections.isEmpty) return null;
    final vectors = detections.where((d) => d.isDengueVector).toList();
    if (vectors.isNotEmpty) {
      vectors.sort((a, b) => b.confidence.compareTo(a.confidence));
      return vectors.first.boundingBox;
    }
    final sorted = List<Detection>.from(detections)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    return sorted.first.boundingBox;
  }

  Future<void> _pickImageFromGallery() async {
    if (_isProcessing) return;
    final loc = AppLocalizations.of(context)!;
    if (!widget.modelReady) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.modelNotReady)));
      }
      return;
    }
    try {
      // Use file_picker for better Windows desktop support
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        dialogTitle: 'Select an image',
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileExtension = filePath.split('.').last.toLowerCase();
        final supportedFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

        if (supportedFormats.contains(fileExtension)) {
          setState(() {
            _isProcessing = true;
            _processingImagePath = filePath;
          });
          try {
            final prediction = await TfliteService().predict(File(filePath));
            final isPositive = prediction.isDengueVector;
            if (mounted) {
              final resultStatus = isPositive ? "positive" : "negative";
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(
                    imagePath: File(filePath),
                    testDate: DateTime.now(),
                    result: resultStatus,
                    confidence: prediction.confidence,
                    sampleType: "Mosquito Image",
                    mosquitoType: prediction.displayName,
                    boundingBox: _primaryBoundingBox(prediction),
                    detections: prediction.detections,
                    imageSize: prediction.imageSize,
                    savedDetectionCount: prediction.detections.length,
                  ),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              final loc = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.predictionFailed(e.toString()))),
              );
            }
          } finally {
            if (mounted) setState(() => _isProcessing = false);
          }
        } else {
          if (mounted) {
            final loc = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(loc.unsupportedFormat)));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.failedPickImage(e.toString()))),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _captureImageFromCamera() async {
    if (_isProcessing) return;
    final loc = AppLocalizations.of(context)!;
    if (!widget.modelReady) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.modelNotReady)));
      }
      return;
    }
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        setState(() {
          _isProcessing = true;
          _processingImagePath = photo.path;
        });
        try {
          final prediction = await TfliteService().predict(File(photo.path));
          final isPositive = prediction.isDengueVector;
          if (mounted) {
            final result = isPositive ? "positive" : "negative";
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultScreen(
                  imagePath: File(photo.path),
                  testDate: DateTime.now(),
                  result: result,
                  confidence: prediction.confidence,
                  sampleType: "Mosquito Image",
                  mosquitoType: prediction.displayName,
                  boundingBox: _primaryBoundingBox(prediction),
                  detections: prediction.detections,
                  imageSize: prediction.imageSize,
                  savedDetectionCount: prediction.detections.length,
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            final l = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l.predictionFailed(e.toString()))),
            );
          }
        } finally {
          if (mounted) setState(() => _isProcessing = false);
        }
      }
    } catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.failedCaptureImage(e.toString()))),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                const HomeHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Hero Section
                          const HeroSection(),

                          const SizedBox(height: 40),

                          // Primary Action - Scan Button
                          ScanButton(
                            key: _scanButtonKey,
                            onTap: _captureImageFromCamera,
                          ),

                          const SizedBox(height: 24),
                          // Secondary Action - Upload
                          UploadButton(
                            key: _uploadButtonKey,
                            onPressed: _pickImageFromGallery,
                          ),

                          const SizedBox(height: 24),

                          // Bite Health Tips Section
                          HealthTipCard(
                            onReadMore: () {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (BuildContext context) {
                                  final loc = AppLocalizations.of(context)!;
                                  return Container(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          loc.treatingAMosquitoBite,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          loc.treatmentSteps,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.5,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF2ECC71,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                            ),
                                            child: Text(
                                              loc.close,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Daily Tip Card
                          const DailyTipCard(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          bottomNavigationBar: NavigationBar(
            key: _navBarKey,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFE8F5E9),
            selectedIndex: 0,
            onDestinationSelected: (index) {
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DengueLensHistory(),
                  ),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PointMapScreen(),
                  ),
                );
              } else if (index == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SymptomQuestionnaireScreen(
                      mosquitoType: 'Unknown mosquito',
                    ),
                  ),
                );
              } else if (index == 4) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EducationalLibraryScreen(),
                  ),
                );
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: Color(0xFF2ECC71)),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                label: 'Point Map',
              ),
              NavigationDestination(
                icon: Icon(Icons.health_and_safety_outlined),
                label: 'Risk Assessment',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_library_outlined),
                label: 'Library',
              ),
            ],
          ),
        ),

        // ── Full-screen Loading Overlay ─────────────────────────────────
        if (_isProcessing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.65),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image preview thumbnail
                  if (_processingImagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_processingImagePath!),
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  const SizedBox(height: 28),
                  // Spinner
                  const SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      color: Color(0xFF2ECC71),
                      strokeWidth: 4,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stage label
                  Builder(
                    builder: (ctx) => Text(
                      AppLocalizations.of(ctx)!.analysingImage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (ctx) => Text(
                      AppLocalizations.of(ctx)!.runningTwoStage,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Onboarding Tutorial Overlay ────────────────────────────────
        if (_showTutorial)
          TutorialOverlay(
            scanKey: _scanButtonKey,
            uploadKey: _uploadButtonKey,
            navBarKey: _navBarKey,
            fabKey: _fabKey,
            onDismiss: () {
              if (mounted) setState(() => _showTutorial = false);
            },
          ),
      ],
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left spacer (keeps title centred)
          const SizedBox(width: 48),
          Text(
            loc.appName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
            tooltip: loc.settings,
            onPressed: () {
              final homeState = context
                  .findAncestorStateOfType<_DengueLensHomeState>();
              homeState?._showSettings();
            },
          ),
        ],
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              height: 1.2,
            ),
            children: [
              TextSpan(text: '${loc.heroTitle1}\n'),
              TextSpan(
                text: loc.heroTitle2,
                style: const TextStyle(color: Color(0xFF2ECC71)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          loc.heroSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
        ),
      ],
    );
  }
}

class ScanButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ScanButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2ECC71),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.scanMosquito,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const UploadButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey[300]!),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      icon: const Icon(
        Icons.photo_library_outlined,
        color: Colors.black87,
        size: 20,
      ),
      label: Text(
        AppLocalizations.of(context)!.uploadFromGallery,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class HealthTipCard extends StatelessWidget {
  final VoidCallback? onReadMore;

  const HealthTipCard({super.key, this.onReadMore});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalizations.of(context)!.healthTipsMosquitoBites,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9), // Light green bg
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: Color(0xFF2ECC71),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.treatingABite,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.treatingABiteDesc,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: onReadMore,
                        child: Text(
                          AppLocalizations.of(context)!.readMore,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2ECC71),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DailyTipCard extends StatelessWidget {
  const DailyTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 80, // Approximate height to match content
            color: const Color(0xFF2ECC71),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF2ECC71),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Builder(
                      builder: (ctx) => RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(ctx)!.tipOfTheDay,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: AppLocalizations.of(ctx)!.dailyTip),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
