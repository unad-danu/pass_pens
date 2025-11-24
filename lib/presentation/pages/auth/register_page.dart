import 'package:flutter/material.dart';

// ➜ Perbaikan: lokasi file sesuai struktur kamu
import 'package:pass_pens/presentation/pages/auth/register_dosen_page.dart';
import 'package:pass_pens/presentation/pages/auth/register_mahasiswa_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    const double maxWidth = 500;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                // ================= HEADER =================
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: h * 0.02),
                  color: const Color(0xFF0D4C73),
                  child: Column(
                    children: [
                      Text(
                        "PASS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: w * 0.07 > 34 ? 34 : w * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: h * 0.004),
                      Text(
                        "PENS Attendance Smart System",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: w * 0.035 > 18 ? 18 : w * 0.035,
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= BACK BUTTON =================
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, top: 10),
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 20),
                      label: const Text(
                        "",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // ================= CONTENT =================
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: w * 0.07),
                    child: Column(
                      children: [
                        SizedBox(height: h * 0.01),

                        // ICON
                        Container(
                          height: h * 0.20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_add_alt_1,
                              size: 80,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: w * 0.045 > 22 ? 22 : w * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ================= CARD PILIHAN =================
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.black26),
                          ),
                          child: Column(
                            children: [
                              // ========== PILIH DOSEN ==========
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: const BorderSide(color: Colors.black),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const RegisterDosenPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Dosen / Lecturer",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // ========== PILIH MAHASISWA ==========
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: const BorderSide(color: Colors.black),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const RegisterMahasiswa(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Mahasiswa / Student",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),

                // ================= FOOTER =================
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: h * 0.02),
                  color: const Color(0xFF0D4C73),
                  child: Column(
                    children: [
                      Text(
                        "Electronic Engineering",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: w * 0.04 > 18 ? 18 : w * 0.04,
                        ),
                      ),
                      Text(
                        "Polytechnic Institute of Surabaya",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: w * 0.04 > 18 ? 18 : w * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
