import 'package:flutter/material.dart';

class MatkulCard extends StatelessWidget {
  final String namaMatkul;
  final String ruangan;
  final String jam;
  final VoidCallback? onTap;

  const MatkulCard({
    super.key,
    required this.namaMatkul,
    required this.ruangan,
    required this.jam,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              namaMatkul,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("Ruangan: $ruangan"),
            Text("Jam: $jam"),
          ],
        ),
      ),
    );
  }
}
