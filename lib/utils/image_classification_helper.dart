import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageClassificationHelper {
  final _modelPath = 'assets/model/mobilenet_quant.tflite';
  final _labelsEnPath = 'assets/model/labels.txt';
  final _labelsZhPath = 'assets/model/labels-zh.txt';

  late final Interpreter _interpreter;
  late final List<String> labelsEn;
  late final List<String> labelsZh;

  bool _isInitialized = false;

  ImageClassificationHelper._();

  static final ImageClassificationHelper instance =
      ImageClassificationHelper._();

  // Load model
  Future<void> _loadModel() async {
    final options = InterpreterOptions();

    // Use XNNPACK Delegate (For Android)
    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
    }

    // Use Metal Delegate (For iOS)
    if (Platform.isIOS) {
      options.addDelegate(GpuDelegate());
    }

    // Load model from assets
    _interpreter = await Interpreter.fromAsset(_modelPath, options: options);

    log('Interpreter loaded successfully');
  }

  // Load labels from assets
  Future<void> _loadLabels() async {
    final labelEnTxt = await rootBundle.loadString(_labelsEnPath);
    labelsEn = labelEnTxt.split('\n');

    final labelZhTxt = await rootBundle.loadString(_labelsZhPath);
    labelsZh = labelZhTxt.split('\n');
  }

  // Initialize helper
  Future<void> _initHelper() async {
    await _loadLabels();
    await _loadModel();
    _isInitialized = true;
  }

  // Process static image and perform inference
  Future<Map<String, double>> inferenceImage(image_lib.Image image) async {
    if (_isInitialized == false) {
      await _initHelper();
    }

    // Resize image to match model input shape (224x224)
    final imageInput = image_lib.copyResize(image, width: 224, height: 224);

    // Convert image to matrix format [height][width][RGB]
    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    // Set tensor input [1, 224, 224, 3]
    final input = [imageMatrix];

    // Set tensor output [1, 1001]
    final output = [List<int>.filled(1001, 0)];

    // Run inference
    _interpreter.run(input, output);

    // Get first output tensor (classification result)
    final result = output.first;

    // Get max score
    final maxScore = result.reduce((a, b) => a + b);

    // Create classification map: {label: score}
    final classification = <String, double>{};
    for (var i = 0; i < result.length; i++) {
      if (result[i] != 0) {
        // Set label: points (normalized by maxScore)
        classification[labelsEn[i]] =
            result[i].toDouble() / maxScore.toDouble();
      }
    }

    return classification;
  }
}
