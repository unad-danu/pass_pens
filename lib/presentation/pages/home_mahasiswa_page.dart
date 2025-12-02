import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_appbar.dart';
import '../pages/detail_matkul_mahasiswa_page.dart';

class HomeMahasiswa extends StatefulWidget {
  const HomeMahasiswa({super.key});

  @override
  State<HomeMahasiswa> createState() => _HomeMahasiswaState();
}

class _HomeMahasiswaState extends State<HomeMahasiswa> {
  final supabase = Supabase.instance.client;

  String search = '';
  bool ascending = true;

  bool loading = true;
  String? errorMessage;
  List<Map<String, dynamic>> dataJadwal = [];

  @override
  void initState() {
    super.initState();
    loadJadwalMahasiswa();
  }

  String _formatTime(dynamic t) {
    if (t == null) return "-";
    final s = t.toString();
    return s.length >= 5 ? s.substring(0, 5) : s;
  }

  Future<void> loadJadwalMahasiswa() async {
    try {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User tidak ditemukan");
      }

      // 1. Ambil data mahasiswa
      final mhsRes = await supabase
          .from('mahasiswa')
          .select('id, prodi_id, kelas, semester')
          .eq('id_auth', user.id)
          .maybeSingle();

      if (mhsRes == null) {
        throw Exception("Data mahasiswa tidak ditemukan");
      }

      final int prodiId = mhsRes['prodi_id'];
      final String kelasMahasiswa = mhsRes['kelas'];
      final int semesterMahasiswa = mhsRes['semester'];

      // 2. Ambil jadwal berdasarkan prodi + kelas + semester matkul
      final jadwalRes = await supabase
          .from('jadwal')
          .select('''
      id,
      hari,
      jam_mulai,
      jam_selesai,
      kelas_mk (
        id,
        nama_kelas
      ),
      matkul (
        id,
        nama_mk,
        kode_mk,
        prodi_id,
        semester
      ),
      dosen (
        id,
        nama
      ),
      ruangan (
        id,
        nama
      )
    ''')
          .eq('matkul.prodi_id', prodiId)
          .eq('kelas_mk.nama_kelas', kelasMahasiswa)
          .eq('matkul.semester', semesterMahasiswa) // ★ FILTER UTAMA
          .order('hari')
          .order('jam_mulai');

      // SUPABASE sudah mengembalikan List<dynamic>
      // Kita simpan langsung ke dataJadwal
      final List<dynamic> raw = jadwalRes;

      final filtered = raw.where((row) {
        final mk = row['matkul'];
        return mk != null &&
            mk['semester'] == semesterMahasiswa &&
            mk['prodi_id'] == prodiId;
      }).toList();

      setState(() {
        dataJadwal = List<Map<String, dynamic>>.from(filtered);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter Search
    List<Map<String, dynamic>> filtered = dataJadwal.where((item) {
      final mk = item['matkul']?['nama_mk'] ?? '';
      return mk.toString().toLowerCase().contains(search.toLowerCase());
    }).toList();

    // Sorting
    final dayOrder = {
      "Senin": 1,
      "Selasa": 2,
      "Rabu": 3,
      "Kamis": 4,
      "Jumat": 5,
      "Sabtu": 6,
      "Minggu": 7,
    };

    filtered.sort((a, b) {
      final hariA = a['hari'] ?? "";
      final hariB = b['hari'] ?? "";

      final orderA = dayOrder[hariA] ?? 999;
      final orderB = dayOrder[hariB] ?? 999;

      return ascending ? orderA.compareTo(orderB) : orderB.compareTo(orderA);
    });

    // === HAPUS DUPLIKAT NAMA MATKUL ===
    final seen = <String>{};
    filtered = filtered.where((item) {
      final mkName = item['matkul']?['nama_mk'] ?? "";
      if (seen.contains(mkName)) return false;
      seen.add(mkName);
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(role: "mhs"),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "Home",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // === SEARCH & SORT ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search matkul",
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black38),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                    onChanged: (v) => setState(() => search = v),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => setState(() => ascending = !ascending),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.sort),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
                    child: Text(
                      "Terjadi kesalahan:\n$errorMessage",
                      textAlign: TextAlign.center,
                    ),
                  )
                : filtered.isEmpty
                ? const Center(child: Text("Tidak ada jadwal"))
                : RefreshIndicator(
                    onRefresh: loadJadwalMahasiswa,
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final row = filtered[index];

                        final matkul = row['matkul'] ?? {};
                        final dosen = row['dosen'] ?? {};
                        final ruangan = row['ruangan'] ?? {};

                        final namaMatkul = matkul['nama_mk'] ?? "Tanpa Nama";
                        final dosenNama = dosen['nama'] ?? "Tidak diketahui";
                        final ruanganNama =
                            ruangan['nama'] ?? "Tidak ada ruang";

                        final hari = row['hari'] ?? "-"; // ★ Tambahan

                        final jam =
                            "${_formatTime(row['jam_mulai'])} - ${_formatTime(row['jam_selesai'])}";

                        final int jadwalId = row['id'];

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailMatkulMahasiswaPage(
                                  jadwalId: jadwalId,
                                  namaMatkul: namaMatkul,
                                  dosen: dosenNama,
                                  ruangan: ruanganNama,
                                  jadwal: jam,
                                  attendanceTerakhir: "Belum ada",
                                  isOffline: true,
                                  latitude: 0.0,
                                  longitude: 0.0,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black45),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      namaMatkul,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Text("Hari : $hari"), // ★ Tambahan
                                const SizedBox(height: 4),
                                Text("Dosen : $dosenNama"),
                                const SizedBox(height: 4),
                                Text("Tempat : $ruanganNama"),
                                const SizedBox(height: 4),
                                Text("Jadwal : $jam"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
