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
    if (s.length >= 5) return s.substring(0, 5);
    return s;
  }

  Future<void> loadJadwalMahasiswa() async {
    try {
      setState(() {
        loading = true;
        errorMessage = null;
        dataJadwal = [];
      });

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

      // Ambil mata kuliah yang diambil mahasiswa (ambil_mk) + join ke jadwal, matkul, dosen, ruangan
      final res = await supabase
          .from('ambil_mk')
          .select('''
            id,
            jadwal_id,
            jadwal (
              id,
              hari,
              jam_mulai,
              jam_selesai,
              matkul:matkul_id ( id, nama_mk, kode_mk ),
              dosen:dosen_id ( id, nama ),
              ruangan:ruangan_id ( id, nama, kode, lokasi )
            )
          ''')
          .eq('mhs_id', mhsId);

      if (!mounted) return;

      setState(() {
        dataJadwal = List<Map<String, dynamic>>.from(res as List<dynamic>);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat jadwal: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = dataJadwal.where((item) {
      final jadwal = item['jadwal'];
      final mk = jadwal?['matkul']?['nama_mk'] ?? '';
      return mk.toString().toLowerCase().contains(search.toLowerCase());
    }).toList();

    filtered.sort((a, b) {
      final mkA = a['jadwal']?['matkul']?['nama_mk'] ?? "";
      final mkB = b['jadwal']?['matkul']?['nama_mk'] ?? "";
      return ascending ? mkA.compareTo(mkB) : mkB.compareTo(mkA);
    });

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

          // SEARCH + SORT
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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Terjadi kesalahan:\n$errorMessage",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : filtered.isEmpty
                ? const Center(child: Text("Tidak ada mata kuliah"))
                : RefreshIndicator(
                    onRefresh: loadJadwalMahasiswa,
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final row = filtered[index];
                        final jadwal = row['jadwal'] ?? {};

                        final matkul = jadwal['matkul'] ?? {};
                        final dosen = jadwal['dosen'] ?? {};
                        final ruangan = jadwal['ruangan'] ?? {};

                        final String namaMatkul =
                            matkul['nama_mk']?.toString() ?? "";
                        final String dosenNama =
                            dosen['nama']?.toString() ?? "";
                        final String ruanganNama =
                            ruangan['nama']?.toString() ?? "";

                        final String jamMulai = _formatTime(
                          jadwal['jam_mulai'],
                        );
                        final String jamSelesai = _formatTime(
                          jadwal['jam_selesai'],
                        );
                        final String jamGabung = "$jamMulai - $jamSelesai";

                        final int jadwalId =
                            (jadwal['id'] ?? row['jadwal_id']) as int;

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
                                  jadwal: jamGabung,
                                  attendanceTerakhir:
                                      "Belum ada", // nanti bisa diisi dari absensi terakhir
                                  isOffline:
                                      true, // sementara: nanti bisa diubah tergantung setting
                                  latitude:
                                      0.0, // belum ada relasi ke ruang_kelas
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
                                // TITLE
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
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),
                                Text("Dosen : $dosenNama"),
                                const SizedBox(height: 4),
                                Text("Tempat : $ruanganNama"),
                                const SizedBox(height: 4),
                                Text("Jadwal : $jamGabung"),
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
