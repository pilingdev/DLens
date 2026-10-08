/// Centralized app constants for DengueLens.
class AppConstants {
  AppConstants._();

  // ML Model Constants
  static const String modelPath = 'Model/best.tflite';
  static const int modelInputSize = 960;
  static const double defaultConfidenceThreshold = 0.40;
  static const double defaultIouThreshold = 0.45;

  // Map & Geo Constants
  /// Fixed community sighting radius per documentation: 100 m.
  static const double communityRadiusMeters = 100.0;
  static const int sightingMaxAgeDays = 7;

  // App Identity
  static const String packageName = 'com.denguelens.app';
}
