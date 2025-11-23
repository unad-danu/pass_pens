import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/services/face_recognition_service.dart';
import '../../core/helpers.dart';

class PresensiMahasiswaPage extends StatefulWidget {
  final String matkul;
  final double latKelas;
  final double lonKelas;

  const PresensiMahasiswaPage({
    super.key,
    required this.matkul,
    required this.latKelas,
    required this.lonKelas,
  });

  @override
  State<PresensiMahasiswaPage> createState() => _PresensiMahasiswaPageState();
}

class _PresensiMahasiswaPageState extends State<PresensiMahasiswaPage> {
  final picker = ImagePicker();
  final faceService = FaceRecognitionService();

  File? imageFile;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await [Permission.camera, Permission.locationWhenInUse].request();
  }

  Future<void> takePhoto() async {
    if (await Permission.camera.isDenied) {
      Helpers.showSnackBar(context, "Izin kamera ditolak!");
      return;
    }

    final img = await picker.pickImage(source: ImageSource.camera);
    if (img == null) return;

    setState(() => imageFile = File(img.path));
  }

  Future<void> submit() async {
    if (imageFile == null) {
      Helpers.showSnackBar(context, "Ambil foto terlebih dahulu!");
      return;
    }

    if (await Permission.locationWhenInUse.isDenied) {
      Helpers.showSnackBar(context, "Izin lokasi ditolak!");
      return;
    }

    setState(() => loading = true);

    // 1. FACE DETECTION
    final isClear = await faceService.isFullFace(imageFile!);
    if (!isClear) {
      setState(() => loading = false);
      Helpers.showSnackBar(context, "Wajah tidak terdeteksi jelas!");
      return;
    }

    // 2. LOCATION CHECK
    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      pos = null;
    }

    if (pos == null) {
      setState(() => loading = false);
      Helpers.showSnackBar(context, "Lokasi tidak ditemukan!");
      return;
    }

    final distance = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      widget.latKelas,
      widget.lonKelas,
    );

    if (distance > 100) {
      setState(() => loading = false);
      Helpers.showSnackBar(context, "Anda berada di luar radius kelas!");
      return;
    }

    // 3. SIMPAN PRESENSI (dummy)
    await Future.delayed(const Duration(seconds: 1));

    setState(() => loading = false);
    Helpers.showSnackBar(context, "Presensi berhasil!");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Presensi - ${widget.matkul}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            imageFile == null
                ? Container(
                    height: 220,
                    color: Colors.grey[300],
                    child: const Center(child: Text("Belum ada foto")),
                  )
                : Image.file(imageFile!, height: 220),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: takePhoto,
              child: const Text("Ambil Foto Selfie"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Submit Presensi"),
            ),
          ],
        ),
      ),
    );
  }
}
