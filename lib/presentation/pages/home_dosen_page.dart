import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/matkul_card.dart';

class HomeDosenPage extends StatelessWidget {
  const HomeDosenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Beranda Dosen"),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MatkulCard(
            namaMatkul: "Sistem Operasi",
            ruangan: "D201",
            jam: "08.00 - 09.40",
            onTap: () {},
          ),
          MatkulCard(
            namaMatkul: "Jaringan Komputer",
            ruangan: "D305",
            jam: "10.00 - 11.40",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
