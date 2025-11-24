// presensi_mahasiswa_page.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/services/face_recognition_service.dart';
import '../../core/helpers.dart';

// ---------- Top-level helper for compute() ----------
Future<bool> _isFullFaceIsolate(String imagePath) async {
  // NOTE: instantiate FaceRecognitionService inside isolate
  final service = FaceRecognitionService();
  return service.isFullFace(File(imagePath));
}

// ---------- Page ----------
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
  final ImagePicker _picker = ImagePicker();

  File? imageFile;
  bool loading = false;

  // ------------ Permission helpers ------------
  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    final res = await Permission.camera.request();
    return res.isGranted;
  }

  Future<bool> _ensureLocationPermission() async {
    // Check permission
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    // Request permission
    final res = await Permission.locationWhenInUse.request();
    if (res.isGranted) return true;

    return false;
  }

  Future<bool> _ensureLocationServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (enabled) return true;
    // Prompt user to enable location (can't programmatically enable)
    return false;
  }

  // ------------ Photo capture ------------
  Future<void> takePhoto() async {
    final ok = await _ensureCameraPermission();
    if (!ok) {
      Helpers.showSnackBar(context, "Izin kamera ditolak!");
      return;
    }

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (picked == null) return;
      if (!mounted) return;
      setState(() => imageFile = File(picked.path));
    } catch (e) {
      Helpers.showSnackBar(context, "Gagal ambil foto: $e");
    }
  }

  // ------------ Submit flow (safe) ------------
  Future<void> submit() async {
    if (imageFile == null) {
      Helpers.showSnackBar(context, "Ambil foto terlebih dahulu!");
      return;
    }

    // Ensure location permission
    if (!await _ensureLocationPermission()) {
      Helpers.showSnackBar(context, "Izin lokasi ditolak!");
      return;
    }

    // Ensure location service enabled
    if (!await _ensureLocationServiceEnabled()) {
      Helpers.showSnackBar(context, "Layanan lokasi mati. Aktifkan GPS.");
      return;
    }

    // Start loading
    if (!mounted) return;
    setState(() => loading = true);

    try {
      // 1) Face recognition in isolate (compute)
      final imagePath = imageFile!.path;
      final bool isClear = await compute(
        _isFullFaceIsolate,
        imagePath,
      ).timeout(const Duration(seconds: 8), onTimeout: () => false);

      if (!isClear) {
        if (!mounted) return;
        setState(() => loading = false);
        Helpers.showSnackBar(context, "Wajah tidak terdeteksi jelas!");
        return;
      }

      // 2) Get current position with timeout and fallback
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 6));
      } catch (e) {
        // fallback to last known position
        try {
          pos = await Geolocator.getLastKnownPosition();
        } catch (_) {
          pos = null;
        }
      }

      if (pos == null) {
        if (!mounted) return;
        setState(() => loading = false);
        Helpers.showSnackBar(context, "Lokasi tidak ditemukan!");
        return;
      }

      // 3) Distance check (in meters)
      final distance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        widget.latKelas,
        widget.lonKelas,
      );

      if (distance > 100) {
        if (!mounted) return;
        setState(() => loading = false);
        Helpers.showSnackBar(context, "Anda berada di luar radius kelas!");
        return;
      }

      // 4) Simulate network / finalizing (kept small)
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      setState(() => loading = false);
      Helpers.showSnackBar(context, "Presensi berhasil!");

      // Kembali ke halaman sebelumnya
      Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => loading = false);
      Helpers.showSnackBar(context, "Terjadi kesalahan: $e");
    }
  }

  @override
  void dispose() {
    imageFile?.delete().ignore(); // attempt cleanup (non-blocking)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B5E86),
        elevation: 0,
        automaticallyImplyLeading: true,
        toolbarHeight: 80,
        title: const Column(
          children: [
            Text(
              "PASS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "PENS Attendance Smart System",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              "Presensi - ${widget.matkul}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black45),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text(
                        "Foto Presensi",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imageFile == null
                          ? Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text("Belum ada foto"),
                              ),
                            )
                          : Image.file(imageFile!, fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : takePhoto,
                      child: const Text("Ambil Foto Selfie"),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : submit,
                      child: loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Submit Presensi"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
