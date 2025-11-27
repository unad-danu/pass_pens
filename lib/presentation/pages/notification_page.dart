import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/notification_card.dart';

class NotificationPage extends StatelessWidget {
  final String role; // "dsn" atau "mhs"

  const NotificationPage({super.key, required this.role});

  List<Map<String, dynamic>> getNotifications() {
    if (role == "dsn") {
      return [
        {
          "title": "Praktikum Bahasa Pemrograman",
          "subtitle":
              "Jadwal untuk matakuliah Praktikum Bahasa Pemrograman sudah tiba, silahkan buka presensi",
          "time": "5min",
          "highlight": true,
        },
        {
          "title": "Bahasa Pemrograman",
          "subtitle":
              "Jadwal untuk matakuliah Bahasa Pemrograman sudah tiba, silahkan buka presensi",
          "time": "1d",
          "highlight": false,
        },
        {
          "title": "Praktikum Bahasa Pemrograman",
          "subtitle":
              "Jadwal untuk matakuliah Praktikum Bahasa Pemrograman sudah tiba, silahkan buka presensi",
          "time": "1w",
          "highlight": false,
        },
      ];
    }

    // MAHASISWA
    return [
      {
        "title": "Praktikum Bahasa Pemrograman",
        "subtitle":
            "Dosen telah membuka presensi offline untuk matakuliah Praktikum Bahasa Pemrograman",
        "time": "5min",
        "highlight": true,
      },
      {
        "title": "Organisasi Mesin & Bahasa Assembly",
        "subtitle":
            "Dosen telah membuka presensi online untuk matakuliah Bahasa Pemrograman",
        "time": "1d",
        "highlight": false,
      },
      {
        "title": "Sensor & Aktuator",
        "subtitle":
            "Dosen telah membuka presensi offline untuk matakuliah Praktikum Bahasa Pemrograman",
        "time": "1d",
        "highlight": false,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final notif = getNotifications();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(role: role),

      body: Column(
        children: [
          const SizedBox(height: 10),

          const Center(
            child: Text(
              "Notifications",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              itemCount: notif.length,
              itemBuilder: (context, index) {
                final n = notif[index];
                return NotificationCard(
                  title: n["title"],
                  subtitle: n["subtitle"],
                  time: n["time"],
                  highlight: n["highlight"],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
