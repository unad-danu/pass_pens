import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/custom_appbar.dart';

class DetailRekapMatkulPage extends StatelessWidget {
  final String namaMatkul;
  final int totalPertemuan;

  DetailRekapMatkulPage({
    super.key,
    required this.namaMatkul,
    required this.totalPertemuan,
  });

  // Dummy data
  final List<int> absensi = [1, 0, 1, 1, 1, 0, 1, 1, 0, 1];

  @override
  Widget build(BuildContext context) {
    int totalHadir = absensi.where((e) => e == 1).length;
    int totalTidakHadir = absensi.where((e) => e == 0).length;

    int mingguSekarang = absensi.length;
    bool belumDimulai = absensi.isEmpty;

    double persen = belumDimulai ? 0 : (totalHadir / absensi.length);

    return Scaffold(
      appBar: CustomAppBar(role: "mhs", title: namaMatkul),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: _RekapHeader(
              nama: namaMatkul,
              mingguSekarang: mingguSekarang,
              totalPertemuan: totalPertemuan,
              totalHadir: totalHadir,
              totalTidakHadir: totalTidakHadir,
              persen: persen,
              belumDimulai: belumDimulai,
            ),
          ),
          const SizedBox(height: 20),

          // LIST PERTEMUAN
          ...List.generate(totalPertemuan, (i) {
            int? status = i < absensi.length ? absensi[i] : null;

            return FadeInUp(
              duration: Duration(milliseconds: 300 + (i * 70)),
              child: _PertemuanCard(
                nomor: i + 1,
                tanggal: "2024-11-${(i + 1).toString().padLeft(2, '0')}",
                status: status,
                belumDimulai: belumDimulai,
              ),
            );
          }),
        ],
      ),
    );
  }
}

//
// HEADER
//
class _RekapHeader extends StatelessWidget {
  final String nama;
  final int mingguSekarang;
  final int totalPertemuan;
  final int totalHadir;
  final int totalTidakHadir;
  final double persen;
  final bool belumDimulai;

  const _RekapHeader({
    required this.nama,
    required this.mingguSekarang,
    required this.totalPertemuan,
    required this.totalHadir,
    required this.totalTidakHadir,
    required this.persen,
    required this.belumDimulai,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header hitam
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              nama,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Content
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: belumDimulai ? Colors.grey.shade300 : Colors.white,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Minggu ke-$mingguSekarang",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                belumDimulai
                    ? "Belum Ada Data Kehadiran"
                    : "${(persen * 100).toStringAsFixed(1)}% Kehadiran",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: belumDimulai
                      ? Colors.black54
                      : (persen >= 0.75 ? Colors.green : Colors.orange),
                ),
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: persen,
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(
                  belumDimulai
                      ? Colors.grey
                      : (persen >= 0.75 ? Colors.green : Colors.orange),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _statBox(
                      label: "Hadir",
                      value: totalHadir,
                      color: Colors.green,
                      icon: Icons.check_circle,
                      disabled: belumDimulai,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statBox(
                      label: "Tidak Hadir",
                      value: totalTidakHadir,
                      color: Colors.red,
                      icon: Icons.cancel,
                      disabled: belumDimulai,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statBox({
    required String label,
    required int value,
    required Color color,
    required IconData icon,
    required bool disabled,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: disabled ? Colors.grey.shade300 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: disabled ? Colors.black45 : color, size: 20),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: disabled ? Colors.black45 : color,
            ),
          ),
        ],
      ),
    );
  }
}

//
// CARD PER PERTEMUAN
//
class _PertemuanCard extends StatelessWidget {
  final int nomor;
  final String tanggal;
  final int? status;
  final bool belumDimulai;

  const _PertemuanCard({
    required this.nomor,
    required this.tanggal,
    required this.status,
    required this.belumDimulai,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String statusText;
    IconData icon;

    if (belumDimulai || status == null) {
      color = Colors.grey;
      statusText = "Belum Dilaksanakan";
      icon = Icons.access_time;
    } else if (status == 1) {
      color = Colors.green;
      statusText = "Hadir";
      icon = Icons.check;
    } else {
      color = Colors.red;
      statusText = "Tidak Hadir";
      icon = Icons.close;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: belumDimulai ? Colors.grey.shade300 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: belumDimulai ? Colors.grey : Colors.blue,
            child: Text(
              nomor.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pertemuan $nomor",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text("Tanggal: $tanggal"),
            ],
          ),

          const Spacer(),

          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
