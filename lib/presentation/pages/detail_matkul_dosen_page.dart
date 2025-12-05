import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/absensi_service.dart';
import '../widgets/custom_appbar.dart';
import 'package:geolocator/geolocator.dart';

class DetailMatkulDosenPage extends StatefulWidget {
  final int jadwalId;
  final String namaMatkul;
  final String jamMulai;
  final String jamSelesai;

  const DetailMatkulDosenPage({
    super.key,
    required this.jadwalId,
    required this.namaMatkul,
    required this.jamMulai,
    required this.jamSelesai,
  });

  @override
  State<DetailMatkulDosenPage> createState() => _DetailMatkulDosenPageState();
}

class _DetailMatkulDosenPageState extends State<DetailMatkulDosenPage> {
  final supabase = Supabase.instance.client;
  final absensiService = AbsensiService();

  DateTime _nowWib() => DateTime.now().toUtc().add(const Duration(hours: 7));
  DateTime _utcToWib(DateTime utc) => utc.add(const Duration(hours: 7));
  DateTime _wibToUtc(DateTime wib) => wib.subtract(const Duration(hours: 7));

  String kelasDetail = "";
  String hari = "-";
  String ruang = "-";
  String? terakhirBuka;

  bool isOpen = false;
  bool isLoading = true;

  List<Map<String, dynamic>> historyPresensi = [];
  List<Map<String, dynamic>> hadir = [];
  List<Map<String, dynamic>> tidakHadir = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final futures = await Future.wait([
      _loadPresensiStatus(),
      _loadPresensiList(),
      _loadKelasDetail(),
    ]);

    setState(() => isLoading = false);
  }

  Future<void> _loadKelasDetail() async {
    final data = await supabase
        .from("jadwal")
        .select('''
        hari,
        last_opened_at,
        ruangan:ruangan_id (nama),
        kelas:kelas_id (
          nama_kelas,
          semester,
          mk_id,
          matkul:mk_id (
            nama_mk,
            prodi_id,
            prodi:prodi_id (nama)
          )
        )
      ''')
        .eq("id", widget.jadwalId)
        .maybeSingle();

    if (data == null) return;

    final dKelas = data["kelas"];
    final semester = dKelas["semester"] ?? "-";
    final kelasHuruf = dKelas["nama_kelas"] ?? "-";
    final prodi = dKelas["matkul"]["prodi"]["nama"] ?? "-";

    setState(() {
      kelasDetail = "$semester$prodi $kelasHuruf";

      hari = data["hari"] ?? "-";
      ruang = data["ruangan"]?["nama"] ?? "-";
      terakhirBuka = data["last_opened_at"];
    });
  }

  Future<void> _loadPresensiStatus() async {
    final data = await supabase
        .from("jadwal")
        .select("is_open")
        .eq("id", widget.jadwalId)
        .maybeSingle();

    isOpen = data?["is_open"] ?? false;
  }

  Future<void> _loadPresensiList() async {
    final data = await supabase
        .from('absensi')
        .select('status, mahasiswa:mhs_id (nama)')
        .eq('jadwal_id', widget.jadwalId);

    hadir = [];
    tidakHadir = [];

    for (var row in data) {
      final nama = row['mahasiswa']?['nama'] ?? "-";
      final status = row['status'] ?? "tidak hadir";

      if (status.toLowerCase() == "hadir") {
        hadir.add({"nama": nama, "status": status});
      } else {
        tidakHadir.add({"nama": nama, "status": status});
      }
    }
  }

  Future<bool> bukaPresensi(
    int jadwalId, {
    required String tipePresensi,
    required double latDosen,
    required double lngDosen,
  }) async {
    try {
      final jadwal = await supabase
          .from('jadwal')
          .select('id, kelas_id, dosen_id, is_open')
          .eq('id', jadwalId)
          .maybeSingle();

      if (jadwal == null) return false;

      final kelasId = jadwal['kelas_id'];
      final dosenId = jadwal['dosen_id'];

      // Tutup presensi lain
      await supabase
          .from('jadwal')
          .update({'is_open': false, 'expired_at': null})
          .eq('kelas_id', kelasId)
          .neq('id', jadwalId);

      // Set waktu expired
      final nowWib = _nowWib();
      final expiredWib = nowWib.add(const Duration(hours: 1));

      // Update jadwal open
      await supabase
          .from('jadwal')
          .update({
            'is_open': true,
            'tipe_presensi': tipePresensi,
            'last_opened_at': _wibToUtc(nowWib).toIso8601String(),
            'expired_at': _wibToUtc(expiredWib).toIso8601String(),
          })
          .eq('id', jadwalId);

      // ======================================
      // SIMPAN LOKASI DOSEN (UPSERT)
      // ======================================
      if (dosenId != null) {
        await supabase.from('dosen_location').upsert({
          'dosen_id': dosenId,
          'lat': latDosen,
          'lng': lngDosen,
        });
      }

      // Insert notif
      await supabase.from('notifications').insert({
        'jadwal_id': jadwalId,
        'role': 'mhs',
        'title': 'Presensi dibuka',
        'subtitle':
            'Presensi $tipePresensi dibuka oleh dosen — akan tutup otomatis dalam 1 jam.',
        'highlight': true,
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  // iki
  Future<void> _bukaPresensi(String mode) async {
    setState(() => isLoading = true);

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 1. Cek apakah sudah ada presensi aktif pada jadwal ini
    final jadwal = await supabase
        .from("jadwal")
        .select("is_open")
        .eq("id", widget.jadwalId)
        .maybeSingle();

    final sudahOpen = jadwal?['is_open'] ?? false;

    if (sudahOpen) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Presensi masih aktif, tidak bisa membuka baru."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Panggil service
    final success = await bukaPresensi(
      widget.jadwalId,
      tipePresensi: mode,
      latDosen: pos.latitude,
      lngDosen: pos.longitude,
    );

    if (!success) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal membuka presensi."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isOpen = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Presensi $mode berhasil dibuka. Akan tutup otomatis dalam 1 jam.",
        ),
        backgroundColor: Colors.green,
      ),
    );

    await _loadAll();
  }

  Future<void> _tutupPresensi() async {
    setState(() => isLoading = true);

    try {
      // Tutup presensi via AbsensiService
      final result = await absensiService.tutupPresensi(widget.jadwalId);

      if (!result) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menutup presensi."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => isOpen = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Presensi telah ditutup."),
          backgroundColor: Colors.green,
        ),
      );

      await _loadAll();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showBack: false, role: "dsn"),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // =========================================
                  // HEADER TITLE
                  // =========================================
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
                        "Detail Matakuliah",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              widget.namaMatkul.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          kelasDetail.isEmpty
                              ? "Kelas : ..."
                              : "Kelas : $kelasDetail",
                        ),

                        Text(
                          "Waktu : ${widget.jamMulai} - ${widget.jamSelesai}",
                        ),

                        const SizedBox(height: 15),

                        Text("Hari : $hari"),
                        Text("Ruangan : $ruang"),
                        Text(
                          "Terakhir Dibuka : ${terakhirBuka == null ? '-' : terakhirBuka!.toString().replaceAll('T', ' ').split('.')[0]}",
                        ),

                        // ========== BUTTONS ==========
                        if (!isOpen) ...[
                          _buildButton(
                            "Offline Presensi",
                            Colors.red,
                            () => _bukaPresensi("offline"),
                          ),
                          const SizedBox(height: 8),
                          _buildButton(
                            "Online Presensi",
                            Colors.blue,
                            () => _bukaPresensi("online"),
                          ),
                        ] else
                          _buildButton(
                            "Tutup Presensi",
                            Colors.grey,
                            _tutupPresensi,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  _buildPresensiList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  Widget _buildPresensiList() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            color: Colors.black,
            child: const Center(
              child: Text(
                "Presensi Mahasiswa",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ==== TIDAK HADIR ====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: Colors.red.withOpacity(0.3),
            child: const Text(
              "Tidak Hadir",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          for (var m in tidakHadir)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text(m["nama"], textAlign: TextAlign.center)),
                  const Expanded(
                    child: Text(
                      "Tidak Hadir",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // ==== HADIR ====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: Colors.green.withOpacity(0.3),
            child: const Text(
              "Hadir",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          for (var m in hadir)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text(m["nama"], textAlign: TextAlign.center)),
                  const Expanded(
                    child: Text(
                      "Hadir",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
