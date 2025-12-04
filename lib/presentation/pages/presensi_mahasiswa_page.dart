import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/services/absensi_service.dart';
import '../../data/services/face_recognition_service.dart';
import '../../core/helpers.dart';
import '../widgets/custom_appbar.dart';
import 'package:image/image.dart' as img;

// isolate
Future<bool> _isFullFaceIsolate(String imagePath) async {
  final service = FaceRecognitionService();
  return service.isFullFace(File(imagePath));
}

class PresensiMahasiswaPage extends StatefulWidget {
  final int mhsId;
  final int jadwalId;
  final String tipePresensi;
  final String matkul;

  const PresensiMahasiswaPage({
    super.key,
    required this.mhsId,
    required this.jadwalId,
    required this.tipePresensi,
    required this.matkul,
  });

  @override
  State<PresensiMahasiswaPage> createState() => _PresensiMahasiswaPageState();
}

class _PresensiMahasiswaPageState extends State<PresensiMahasiswaPage> {
  final ImagePicker _picker = ImagePicker();
  final AbsensiService absensiService = AbsensiService();

  // 🔥 tipe presensi yang akan dipakai, default dari parent
  String tipePresensi = "";

  File? imageFile;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    tipePresensi = widget.tipePresensi; // default
    loadTipePresensi(); // 🔥 AMBIL DARI DATABASE
  }

  // =======================================================
  // 🔥🔥 AMBIL TIPE PRESENSI DARI SUPABASE (TAMBAHAN)
  // =======================================================
  Future<void> loadTipePresensi() async {
    final data = await Supabase.instance.client
        .from('jadwal')
        .select('tipe_presensi')
        .eq('id', widget.jadwalId)
        .maybeSingle();

    if (data != null && mounted) {
      setState(() {
        tipePresensi = data['tipe_presensi'] ?? widget.tipePresensi;
      });
    }
  }

  // CAMERA PERMISSION
  Future<bool> _ensureCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final req = await Permission.camera.request();
      return req.isGranted;
    }

    if (status.isPermanentlyDenied) {
      Helpers.showSnackBar(context, "Izinkan kamera dari pengaturan!");
      await openAppSettings();
      return false;
    }

    return false;
  }

  // LOCATION PERMISSION
  Future<bool> _ensureLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final req = await Permission.locationWhenInUse.request();
      return req.isGranted;
    }

    if (status.isPermanentlyDenied) {
      Helpers.showSnackBar(context, "Aktifkan izin lokasi di pengaturan!");
      await openAppSettings();
      return false;
    }

    return false;
  }

  // CHECK GPS
  Future<bool> _ensureLocationServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (enabled) return true;

    Helpers.showSnackBar(context, "GPS belum aktif! Mohon aktifkan GPS.");
    await Geolocator.openLocationSettings();
    await Future.delayed(const Duration(seconds: 2));

    return await Geolocator.isLocationServiceEnabled();
  }

  // TAKE PHOTO
  Future<void> takePhoto() async {
    if (!await _ensureCameraPermission()) return;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );

      if (picked == null) return;

      // Fix orientation
      final bytes = await picked.readAsBytes();
      final original = img.decodeImage(bytes);

      if (original == null) {
        Helpers.showSnackBar(context, "Gagal membaca foto!");
        return;
      }

      final fixed = img.copyRotate(original, angle: 0);
      final fixedPath = picked.path;

      File(fixedPath).writeAsBytesSync(img.encodeJpg(fixed));

      setState(() => imageFile = File(fixedPath));
    } catch (e) {
      Helpers.showSnackBar(context, "Gagal mengakses kamera: $e");
    }
  }

  // SUBMIT PRESENSI
  Future<void> submit() async {
    // Mode online
    if (tipePresensi == "online") {
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
        log(e.toString(), name: 'PresensiOnlineError');
      }

      return;
    }

    // Mode offline (foto + GPS)
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
      final clear = await FaceRecognitionService().isFullFace(imageFile!);

      if (!clear) {
        setState(() => loading = false);
        Helpers.showSnackBar(context, "Wajah tidak terdeteksi dengan jelas!");
        return;
      }

      Position pos;

      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
      } catch (e) {
        Helpers.showSnackBar(context, "Gagal mendapatkan lokasi: $e");
        setState(() => loading = false);
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
                        tipePresensi == "online"
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
                  if (tipePresensi == "offline") ...[
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
