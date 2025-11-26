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
      appBar: CustomAppBar(
        role: "dsn",
        showBack: true,
        title: "Presensi Dosen - ${widget.matkul}",
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
