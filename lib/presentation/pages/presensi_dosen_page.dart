import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class PresensiDosenPage extends StatefulWidget {
  final String matkul;

  const PresensiDosenPage({super.key, required this.matkul});

  @override
  State<PresensiDosenPage> createState() => _PresensiDosenPageState();
}

class _PresensiDosenPageState extends State<PresensiDosenPage> {
  bool presensiAktif = false;

  List<String> hadir = ["Mahasiswa 1", "Mahasiswa 2", "Mahasiswa 3"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(role: "dsn", showBack: false),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ============================
            /// TOMBOL BACK DI BODY
            /// ============================
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Presensi Dosen - ${widget.matkul}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text("Presensi Aktif"),
              value: presensiAktif,
              onChanged: (v) {
                setState(() => presensiAktif = v);
              },
            ),

            const Divider(height: 32),

            const Text(
              "Mahasiswa Hadir:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: hadir.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text(hadir[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
