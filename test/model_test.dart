import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:DengueLens/utils/constants.dart';

void main() {
  test('inspect tflite model', skip: 'Requires native tflite binaries – run manually', () async {
    final interpreter = Interpreter.fromFile(File(AppConstants.modelPath));
    debugPrint('Input tensors:');
    for (var tensor in interpreter.getInputTensors()) {
      debugPrint('${tensor.name}: ${tensor.shape} (type: ${tensor.type})');
    }
    
    debugPrint('Output tensors:');
    for (var tensor in interpreter.getOutputTensors()) {
      debugPrint('${tensor.name}: ${tensor.shape} (type: ${tensor.type})');
    }
  });
}
