import 'package:flutter/material.dart';

class DetailMatkulDosenPage extends StatelessWidget {
  final String nama;
  final String ruangan;
  final String jam;

  const DetailMatkulDosenPage({
    super.key,
    required this.nama,
    required this.ruangan,
    required this.jam,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nama)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mata Kuliah: $nama",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text("Ruangan: $ruangan"),
            Text("Jam: $jam"),
          ],
        ),
      ),
    );
  }
}
