import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/services/absensi_service.dart';
import '../../data/services/face_recognition_service.dart';
import '../../core/helpers.dart';
import '../widgets/custom_appbar.dart';

Future<bool> _isFullFaceIsolate(String imagePath) async {
  final service = FaceRecognitionService();
  return service.isFullFace(File(imagePath));
}

class PresensiMahasiswaPage extends StatefulWidget {
  final int mhsId;
  final int jadwalId;
  final String tipePresensi; // 'online' atau 'offline'
  final String matkul;
  final double latKelas;
  final double lonKelas;

  const PresensiMahasiswaPage({
    super.key,
    required this.mhsId,
    required this.jadwalId,
    required this.tipePresensi,
    required this.matkul,
    required this.latKelas,
    required this.lonKelas,
  });

  @override
  State<PresensiMahasiswaPage> createState() => _PresensiMahasiswaPageState();
}

class _PresensiMahasiswaPageState extends State<PresensiMahasiswaPage> {
  final ImagePicker _picker = ImagePicker();
  final AbsensiService absensiService = AbsensiService();

  File? imageFile;
  bool loading = false;

  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    final res = await Permission.camera.request();
    return res.isGranted;
  }

  Future<bool> _ensureLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    final res = await Permission.locationWhenInUse.request();
    return res.isGranted;
  }

  Future<bool> _ensureLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<void> takePhoto() async {
    if (!await _ensureCameraPermission()) {
      Helpers.showSnackBar(context, "Izin kamera ditolak!");
      return;
    }

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => imageFile = File(picked.path));
    } catch (e) {
      Helpers.showSnackBar(context, "Gagal ambil foto: $e");
    }
  }

  Future<void> submit() async {
    // ===============================
    // MODE ONLINE (langsun presensi)
    // ===============================
    if (widget.tipePresensi == "online") {
      setState(() => loading = true);

      try {
        await absensiService.presensiOnline(
          mhsId: widget.mhsId,
          jadwalId: widget.jadwalId,
        );

        setState(() => loading = false);
        Helpers.showSnackBar(context, "Presensi Online Berhasil!");
        Navigator.pop(context);
      } catch (e) {
        setState(() => loading = false);
        Helpers.showSnackBar(context, "Gagal presensi: $e");
      }

      return;
    }

    // ===============================
    // MODE OFFLINE (foto + lokasi)
    // ===============================
    if (imageFile == null) {
      Helpers.showSnackBar(context, "Ambil foto terlebih dahulu!");
      return;
    }

    if (!await _ensureLocationPermission()) {
      Helpers.showSnackBar(context, "Izin lokasi ditolak!");
      return;
    }

    if (!await _ensureLocationServiceEnabled()) {
      Helpers.showSnackBar(context, "GPS belum aktif!");
      return;
    }

    setState(() => loading = true);

    try {
      final clear = await compute(_isFullFaceIsolate, imageFile!.path);

      if (!clear) {
        setState(() => loading = false);
        Helpers.showSnackBar(context, "Wajah tidak terdeteksi dengan jelas!");
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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

      await absensiService.presensiOffline(
        mhsId: widget.mhsId,
        jadwalId: widget.jadwalId,
        foto: imageFile!,
        lat: pos.latitude,
        lng: pos.longitude,
      );

      setState(() => loading = false);
      Helpers.showSnackBar(context, "Presensi Offline Berhasil!");
      Navigator.pop(context);
    } catch (e) {
      setState(() => loading = false);
      Helpers.showSnackBar(context, "Terjadi kesalahan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: const CustomAppBar(role: "mhs", title: "Presensi Mahasiswa"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),

            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Presensi - ${widget.matkul}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
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
                    child: Center(
                      child: Text(
                        widget.tipePresensi == "online"
                            ? "Presensi Online"
                            : "Foto Presensi",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TAMPILKAN FOTO HANYA JIKA OFFLINE
                  if (widget.tipePresensi == "offline") ...[
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
                  ],

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
