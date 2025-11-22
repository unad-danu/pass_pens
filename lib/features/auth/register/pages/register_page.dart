import 'package:flutter/material.dart';
import 'package:pass_pens/features/auth/register/pages/register_dosen_page.dart';
import 'package:pass_pens/features/auth/register/pages/register_mahasiswa_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER BIRU
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25),
            width: double.infinity,
            color: const Color(0xFF0D4C73),
            child: const Column(
              children: [
                Text(
                  "PASS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "PENS Attendance Smart System",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // BACK BUTTON
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // ICON
          Image.asset("assets/icon_login.png", width: 180, height: 180),

          const SizedBox(height: 10),
          const Text(
            "Create Account",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          // CARD PILIHAN ROLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black38),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterDosenPage(),
                          ),
                        );
                      },
                      child: const Text("Dosen / Lecturer"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterMahasiswaPage(),
                          ),
                        );
                      },
                      child: const Text("Mahasiswa / Student"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // FOOTER
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            width: double.infinity,
            color: const Color(0xFF0D4C73),
            child: const Text(
              "Electronic Engineering\nPolytechnic Institute of Surabaya",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
