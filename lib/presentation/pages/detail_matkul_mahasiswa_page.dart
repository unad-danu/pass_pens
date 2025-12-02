import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presensi_mahasiswa_page.dart';
import '../widgets/custom_appbar.dart';

class DetailMatkulMahasiswaPage extends StatefulWidget {
  final int jadwalId;
  final String namaMatkul;
  final String dosen;
  final String ruangan;
  final String jadwal;
  final String attendanceTerakhir;
  final bool isOffline;
  final double latitude;
  final double longitude;

  const DetailMatkulMahasiswaPage({
    super.key,
    required this.jadwalId,
    required this.namaMatkul,
    required this.dosen,
    required this.ruangan,
    required this.jadwal,
    required this.attendanceTerakhir,
    required this.isOffline,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<DetailMatkulMahasiswaPage> createState() =>
      _DetailMatkulMahasiswaPageState();
}

class _DetailMatkulMahasiswaPageState extends State<DetailMatkulMahasiswaPage> {
  final supabase = Supabase.instance.client;

  bool isLoadingHistory = true;
  String? errorMessage;
  List<Map<String, dynamic>> historyAbsensi = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) {
        throw "Tidak ada user login";
      }

      // Cari mahasiswa berdasarkan id_auth
      final mhsRow = await supabase
          .from('mahasiswa')
          .select('id')
          .eq('id_auth', authUser.id)
          .maybeSingle();

      if (mhsRow == null) {
        throw "Data mahasiswa tidak ditemukan";
      }

      final int mhsId = mhsRow['id'] as int;

      final data = await supabase
          .from('absensi')
          .select('id, dibuat, status, tipe, pertemuan')
          .eq('mhs_id', mhsId)
          .eq('jadwal_id', widget.jadwalId)
          .order('dibuat', ascending: false);

      if (!mounted) return;

      setState(() {
        historyAbsensi = List<Map<String, dynamic>>.from(data as List<dynamic>);
        isLoadingHistory = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingHistory = false;
        errorMessage = e.toString();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat history: $e")));
    }
  }

  String _formatDateTime(dynamic v) {
    if (v == null) return "-";
    final s = v.toString();
    // format: "2025-11-30 10:23:45"
    return s.replaceAll('T', ' ').split(".").first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showBack: false, role: "mhs"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + Back
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back, size: 28),
                    ),
                  ),
                ),
                const Text(
                  "Detail Matakuliah",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Card Matkul
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
                        widget.namaMatkul,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text("Dosen : ${widget.dosen}"),
                  const SizedBox(height: 4),
                  Text("Tempat : ${widget.ruangan}"),
                  const SizedBox(height: 4),
                  Text("Jadwal : ${widget.jadwal}"),
                  const SizedBox(height: 4),
                  Text("Attendance Terakhir : ${widget.attendanceTerakhir}"),

                  const SizedBox(height: 20),

                  // Tombol Presensi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isOffline
                            ? Colors.red
                            : Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (widget.isOffline) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PresensiMahasiswaPage(
                                matkul: widget.namaMatkul,
                                latKelas: widget.latitude,
                                lonKelas: widget.longitude,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Presensi Online dilakukan! (dummy)",
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Presensi",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // History Presensi student (berdasarkan absensi)
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
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
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

                  if (isLoadingHistory)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (historyAbsensi.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Belum ada data presensi."),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        children: [
                          // header
                          Container(
                            color: Colors.lightBlue[100],
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "ID",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Tanggal",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Status",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          for (var row in historyAbsensi)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      row["id"].toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _formatDateTime(row["dibuat"]),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      row["status"]?.toString() ?? "",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
