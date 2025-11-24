import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/services/face_recognition_service.dart';
import '../../core/helpers.dart';
import '../../routes/app_routes.dart';

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

  int currentIndex = 2; // Presensi berada di posisi ke-2 (0,1,**2**,3)

  void handleNavTap(int index) {
    setState(() => currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.homeMahasiswa);
        break;

      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.notification);
        break;

      case 2:
        // halaman ini → tidak pindah
        break;

      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
    }
  }

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

    final isClear = await faceService.isFullFace(imageFile!);
    if (!isClear) {
      setState(() => loading = false);
      Helpers.showSnackBar(context, "Wajah tidak terdeteksi jelas!");
      return;
    }

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

    await Future.delayed(const Duration(seconds: 1));

    setState(() => loading = false);
    Helpers.showSnackBar(context, "Presensi berhasil!");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =====================================================
      // HEADER (sama persis NotificationPage)
      // =====================================================
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

      // =====================================================
      // BODY — mengikuti gaya NOTIFICATION CARD STYLE
      // =====================================================
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

            // CARD GAYA NOTIF
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black45),
              ),
              child: Column(
                children: [
                  // Header card (hitam seperti notif)
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

                  // FOTO PREVIEW
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

                  // TOMBOL AMBIL FOTO
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: takePhoto,
                      child: const Text("Ambil Foto Selfie"),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // TOMBOL SUBMIT
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : submit,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text("Submit Presensi"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // =====================================================
      // BOTTOM NAV — 100% sama NotificationPage
      // =====================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF0B5E86),
        unselectedItemColor: Colors.black54,
        onTap: handleNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notif",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Presensi",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
