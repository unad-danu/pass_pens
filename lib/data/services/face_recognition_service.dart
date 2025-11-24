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
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) return false;

      final face = faces.first;
      final box = face.boundingBox;

      // Cek ukuran wajah minimal (lebih realistis)
      if (box.width < 80 || box.height < 80) {
        return false;
      }

      // Cek kemiringan kepala
      final angleY = face.headEulerAngleY ?? 0;
      if (angleY.abs() > 25) return false;

      return true;
    } catch (e) {
      return false;
    } finally {
      // ini yang benar
      faceDetector.close();
    }
  }
}
