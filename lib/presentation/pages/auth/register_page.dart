import 'package:flutter/material.dart';

// ➜ Perbaikan: lokasi file sesuai struktur kamu
import 'package:pass_pens/presentation/pages/auth/register_dosen_page.dart';
import 'package:pass_pens/presentation/pages/auth/register_mahasiswa_page.dart';
import 'package:pass_pens/presentation/widgets/custom_appbar.dart';

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

      appBar: const CustomAppBar(showBack: false),
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                // ================= BACK BUTTON =================
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, top: 10),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Colors.black, // ← warna hitam
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

                        Container(
                          height: 150,
                          width: 150,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.asset(
                            'assets/icon_login.png',
                            fit: BoxFit.cover,
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

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.black26),
                          ),
                          child: Column(
                            children: [
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
              ],
            ),
          ),
        ),
      ),

      // ====== DIPINDAH KE SINI (UI TIDAK BERUBAH) ======
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        width: double.infinity,
        color: const Color(0xFF0D4C73),
        child: const SafeArea(
          top: false,
          child: Text(
            "Electronic Engineering\nPolytechnic Institute of Surabaya",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
