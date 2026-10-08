import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'package:DengueLens/utils/constants.dart';

void main() {
  test('Inspect TFLite models', skip: 'Requires native tflite binaries – run manually', () async {
    try {
      final modelFile = File(AppConstants.modelPath);
      if (modelFile.existsSync()) {
        final interpreter = Interpreter.fromFile(modelFile);
        debugPrint('Model: ${AppConstants.modelPath}');
        debugPrint('Inputs:');
        for (var tensor in interpreter.getInputTensors()) {
          debugPrint(' - ${tensor.name}: shape=${tensor.shape}, type=${tensor.type}');
        }
        debugPrint('Outputs:');
        for (var tensor in interpreter.getOutputTensors()) {
          debugPrint(' - ${tensor.name}: shape=${tensor.shape}, type=${tensor.type}');
        }
      } else {
        debugPrint('Model file not found at ${modelFile.path}');
      }
    } catch (e, stack) {
      debugPrint('Error: $e\n$stack');
    }
  });
}
