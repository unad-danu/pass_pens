import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceRecognitionService {
  final options = FaceDetectorOptions(
    enableClassification: true,
    enableContours: true,
    performanceMode: FaceDetectorMode.accurate,
  );

  Future<bool> isFullFace(File imageFile) async {
    final faceDetector = FaceDetector(options: options);

    try {
      // Load image with correct orientation
      final inputImage = InputImage.fromFilePath(imageFile.path);

      final faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) return false;

      final face = faces.first;
      final box = face.boundingBox;

      // Flexible bounding box
      if (box.width < 40 || box.height < 40) return false;

      // Check tilt (Y)
      final angleY = face.headEulerAngleY ?? 0;
      if (angleY.abs() > 40) return false;

      // Check nodding (X)
      final angleX = face.headEulerAngleX ?? 0;
      if (angleX.abs() > 35) return false;

      return true;
    } catch (e) {
      return false;
    } finally {
      faceDetector.close();
    }
  }
}
