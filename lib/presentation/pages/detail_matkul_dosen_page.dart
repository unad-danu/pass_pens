import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_appbar.dart';
import '../../services/absensi_service.dart';

class DetailMatkulDosenPage extends StatefulWidget {
  final int jadwalId;
  final String nama;
  final String ruangan;
  final String jam;

  const DetailMatkulDosenPage({
    super.key,
    required this.jadwalId,
    required this.nama,
    required this.ruangan,
    required this.jam,
  });

  @override
  State<DetailMatkulDosenPage> createState() => _DetailMatkulDosenPageState();
}

class _DetailMatkulDosenPageState extends State<DetailMatkulDosenPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  List<Map<String, dynamic>> historyPresensi = [];
  List<Map<String, dynamic>> hadir = [];
  List<Map<String, dynamic>> tidakHadir = [];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      // Load history presensi
      final dataHistory = await supabase
          .from('presensi')
          .select('id, created_at')
          .eq('jadwal_id', widget.jadwalId)
          .order('created_at', ascending: false);

      // Load presensi mahasiswa
      final presensiDetail = await supabase
          .from('presensi_detail')
          .select('status, mahasiswa (nama)')
          .eq('jadwal_id', widget.jadwalId);

      List<Map<String, dynamic>> hadirTmp = [];
      List<Map<String, dynamic>> tidakHadirTmp = [];

      for (var row in presensiDetail) {
        final nama = row['mahasiswa']?['nama'] ?? '-';
        final status = row['status'] ?? 'Tidak Hadir';

        if (status == "Hadir") {
          hadirTmp.add({"nama": nama, "status": status});
        } else {
          tidakHadirTmp.add({"nama": nama, "status": status});
        }
      }

      setState(() {
        historyPresensi = List<Map<String, dynamic>>.from(dataHistory);
        hadir = hadirTmp;
        tidakHadir = tidakHadirTmp;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ===========================================
  // FUNGSI BUKA PRESENSI ONLINE / OFFLINE
  // ===========================================
  Future<void> _bukaPresensi(String tipe) async {
    final absensiService = AbsensiService();

    final success = await absensiService.bukaPresensi(widget.jadwalId, tipe);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Presensi $tipe berhasil dibuka!")),
      );
      _loadDetail();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal membuka presensi")));
    }
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BACK + TITLE
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

                  // CARD DETAIL MATKUL
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
                              widget.nama.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Text("Ruangan : ${widget.ruangan}"),
                        const SizedBox(height: 4),
                        Text("Jadwal : ${widget.jam}"),
                        const SizedBox(height: 15),

                        // =======================
                        // BUTTON OFFLINE PRESENSI
                        // =======================
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              _bukaPresensi("Offline");
                            },
                            child: const Text("Offline Presensi"),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // =======================
                        // BUTTON ONLINE PRESENSI
                        // =======================
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () {
                              _bukaPresensi("Online");
                            },
                            child: const Text("Online Presensi"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // HISTORY
                  Container(
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
                              "History Presensi",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (historyPresensi.isEmpty)
                          const Text("Belum ada presensi."),

                        for (var item in historyPresensi)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("ID: ${item['id']}"),
                                Text(
                                  item['created_at']
                                      .toString()
                                      .replaceAll('T', ' ')
                                      .split(".")[0],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // PRESENSI MAHASISWA
                  Container(
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

                        // TIDAK HADIR
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
                                Expanded(
                                  child: Text(
                                    m["nama"],
                                    textAlign: TextAlign.center,
                                  ),
                                ),
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

                        // HADIR
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
                                Expanded(
                                  child: Text(
                                    m["nama"],
                                    textAlign: TextAlign.center,
                                  ),
                                ),
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
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
