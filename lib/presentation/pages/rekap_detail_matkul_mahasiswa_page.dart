import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_appbar.dart';

class DetailRekapMatkulPage extends StatefulWidget {
  final String namaMatkul;
  final int totalPertemuan;

  const DetailRekapMatkulPage({
    super.key,
    required this.namaMatkul,
    required this.totalPertemuan,
  });

  @override
  State<DetailRekapMatkulPage> createState() => _DetailRekapMatkulPageState();
}

class _DetailRekapMatkulPageState extends State<DetailRekapMatkulPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> absensi = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadRekap();
  }

  Future<void> loadRekap() async {
    try {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User tidak ditemukan.");

      final mhsRes = await supabase
          .from("mahasiswa")
          .select("id")
          .eq("id_auth", user.id)
          .maybeSingle();

      if (mhsRes == null) throw Exception("Data mahasiswa tidak ditemukan.");
      final int mhsId = mhsRes["id"] as int;

      final jadwalRes = await supabase
          .from("jadwal")
          .select("""
            id,
            matkul(nama_mk)
          """)
          .eq("matkul.nama_mk", widget.namaMatkul)
          .maybeSingle();

      if (jadwalRes == null) throw Exception("Jadwal tidak ditemukan.");
      final int jadwalId = jadwalRes["id"] as int;

      final absensiRes = await supabase
          .from("absensi")
          .select("""
            pertemuan,
            status,
            dibuat
          """)
          .eq("mhs_id", mhsId)
          .eq("jadwal_id", jadwalId)
          .order('pertemuan', ascending: true);

      final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        absensiRes ?? [],
      );

      setState(() {
        absensi = list;
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  int? _normalizeStatus(dynamic s) {
    if (s == null) return null;
    if (s is int) return s;

    final st = s.toString().toLowerCase();
    if (st == 'hadir' || st == '1' || st == 'true') return 1;
    if (st == 'alpha' || st == 'alpa' || st == 'tidak hadir' || st == '0')
      return 0;
    return null;
  }

  DateTime? _parseTanggal(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  DateTime _estimate(int i) {
    final base = DateTime.now();
    return base.add(Duration(days: i * 7));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: const CustomAppBar(role: "mhs"),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: const CustomAppBar(role: "mhs"),
        body: Center(child: Text(errorMessage!)),
      );
    }

    int totalHadir = 0;
    int totalTidakHadir = 0;

    for (final a in absensi) {
      final st = _normalizeStatus(a["status"]);
      if (st == 1) totalHadir++;
      if (st == 0) totalTidakHadir++;
    }

    final mingguAda = <int>{
      for (final a in absensi)
        if (a["pertemuan"] != null) (a["pertemuan"] as int),
    };

    final mingguSekarang = mingguAda.length;
    final belumDimulai = absensi.isEmpty;
    final double persen = (totalHadir + totalTidakHadir == 0)
        ? 0.0
        : (totalHadir / (totalHadir + totalTidakHadir)).toDouble();

    return Scaffold(
      appBar: const CustomAppBar(role: "mhs"),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back, size: 28),
                  ),
                ),
              ),
              const Text(
                "Rekap Presensi",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 15),
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: _RekapHeader(
              nama: widget.namaMatkul,
              mingguSekarang: mingguSekarang,
              totalPertemuan: widget.totalPertemuan,
              totalHadir: totalHadir,
              totalTidakHadir: totalTidakHadir,
              persen: persen,
              belumDimulai: belumDimulai,
            ),
          ),
          const SizedBox(height: 20),

          ...List.generate(widget.totalPertemuan, (i) {
            final minggu = i + 1;

            final found = absensi.firstWhere(
              (x) => (x["pertemuan"] == minggu),
              orElse: () => {},
            );

            final statusRaw = found.isNotEmpty ? found["status"] : null;
            final status = _normalizeStatus(statusRaw);

            final tRaw = found.isNotEmpty
                ? (found["dibuat"] ?? found["created_at"] ?? found["created"])
                : null;

            final parsed = _parseTanggal(tRaw);
            final tanggal = parsed ?? _estimate(i);

            final belum = status == null;

            return FadeInUp(
              duration: Duration(milliseconds: 300 + (i * 70)),
              child: _PertemuanCard(
                nomor: minggu,
                tanggal: tanggal,
                status: status,
                belumDimulai: belum,
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// =================================================================
///                    REKAP HEADER WIDGET
/// =================================================================

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

/// =================================================================
///                    CARD PER PERTEMUAN
/// =================================================================

class _PertemuanCard extends StatelessWidget {
  final int nomor;
  final DateTime tanggal;
  final int? status;
  final bool belumDimulai;

  const _PertemuanCard({
    required this.nomor,
    required this.tanggal,
    required this.status,
    required this.belumDimulai,
  });

  String formatTanggal(DateTime date) {
    const hari = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu",
    ];

    const bulan = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];

    return "${hari[date.weekday - 1]}, ${date.day} ${bulan[date.month - 1]} ${date.year}";
  }

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
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
                Text(
                  formatTanggal(tanggal),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
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
