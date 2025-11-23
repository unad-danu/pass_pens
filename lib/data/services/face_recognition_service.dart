import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceRecognitionService {
  final options = FaceDetectorOptions(
    enableClassification: true,
    enableTracking: false,
    enableContours: true,
    performanceMode: FaceDetectorMode.accurate,
  );

  Future<bool> isFullFace(File imageFile) async {
    final faceDetector = FaceDetector(options: options);
    final inputImage = InputImage.fromFile(imageFile);

    final faces = await faceDetector.processImage(inputImage);

    // Tidak ada wajah
    if (faces.isEmpty) return false;

    // Ambil wajah pertama
    final face = faces.first;

    // Gunakan bounding box sebagai acuan "full face"
    final boundingBox = face.boundingBox;

    // Penilaian sederhana: ukuran wajah cukup besar dan tidak terlalu miring
    if (boundingBox.width < 120 || boundingBox.height < 120) {
      return false;
    }

    // Optional: cek apakah wajah terlihat frontal (angle kecil)
    if (face.headEulerAngleY != null && face.headEulerAngleY!.abs() > 20)
      return false;

    await faceDetector.close();
    return true;
  }
}
