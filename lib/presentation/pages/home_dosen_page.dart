import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/custom_appbar.dart';
import 'package:pass_pens/presentation/pages/detail_matkul_dosen_page.dart';

class HomeDosenPage extends StatefulWidget {
  const HomeDosenPage({super.key});

  @override
  State<HomeDosenPage> createState() => _HomeDosenPageState();
}

class MatkulDosen {
  final int jadwalId;
  final String nama;
  final String ruangan;
  final String jam;
  final String hari;

  MatkulDosen({
    required this.jadwalId,
    required this.nama,
    required this.ruangan,
    required this.jam,
    required this.hari,
  });
}

class _HomeDosenPageState extends State<HomeDosenPage> {
  final supabase = Supabase.instance.client;

  String search = "";
  bool ascending = true;

  bool isLoading = true;
  String? errorMessage;
  List<MatkulDosen> jadwalList = [];

  @override
  void initState() {
    super.initState();
    _loadJadwalDosen();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatTime(dynamic t) {
    if (t == null) return "-";
    final s = t.toString();
    if (s.length >= 5) return s.substring(0, 5);
    return s;
  }

  Future<void> _loadJadwalDosen() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      jadwalList = [];
    });

    try {
      // 1. Ambil user auth (uuid)
      final authUser = supabase.auth.currentUser;
      if (authUser == null) {
        throw "Tidak ada user login (authUser null)";
      }

      // 2. Cari user.id dari tabel users berdasarkan id_auth
      final userRow = await supabase
          .from('users')
          .select('id')
          .eq('id_auth', authUser.id)
          .maybeSingle();

      if (userRow == null) {
        throw "Data user tidak ditemukan di tabel users.";
      }

      final int userId = userRow['id'] as int;

      // 3. Cari dosen.id dari tabel dosen berdasarkan user_id
      final dosenRow = await supabase
          .from('dosen')
          .select('id, nama')
          .eq('user_id', userId)
          .maybeSingle();

      if (dosenRow == null) {
        throw "Data dosen tidak ditemukan untuk user ini.";
      }

      final int dosenId = dosenRow['id'] as int;

      // 4. Ambil jadwal untuk dosen tersebut + join matkul & ruangan
      final rawJadwal = await supabase
          .from('jadwal')
          .select(
            'id, hari, jam_mulai, jam_selesai, matkul ( nama_mk ), ruangan ( nama )',
          )
          .eq('dosen_id', dosenId)
          .order('hari', ascending: true);

      final List<MatkulDosen> temp = [];

      for (final row in rawJadwal as List<dynamic>) {
        final mk = row['matkul'];
        final ruang = row['ruangan'];

        final namaMk = (mk != null ? mk['nama_mk'] : null)?.toString() ?? '-';
        final namaRuang =
            (ruang != null ? ruang['nama'] : null)?.toString() ?? '-';

        final jamMulai = _formatTime(row['jam_mulai']);
        final jamSelesai = _formatTime(row['jam_selesai']);
        final jamGabung = "$jamMulai - $jamSelesai";

        temp.add(
          MatkulDosen(
            jadwalId: row['id'] as int,
            nama: namaMk,
            ruangan: namaRuang,
            jam: jamGabung,
            hari: (row['hari'] ?? '').toString(),
          ),
        );
      }

      setState(() {
        jadwalList = temp;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
      _showMessage("Gagal memuat jadwal: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter + sort berdasarkan nama matkul
    List<MatkulDosen> filtered = jadwalList
        .where((m) => m.nama.toLowerCase().contains(search.toLowerCase()))
        .toList();

    filtered.sort(
      (a, b) => ascending ? a.nama.compareTo(b.nama) : b.nama.compareTo(a.nama),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(role: "dsn"),
      body: Column(
        children: [
          const SizedBox(height: 10),

          const Center(
            child: Text(
              "Home",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
                      hintText: "Search berdasarkan nama matkul",
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
                    child: Icon(ascending ? Icons.sort_by_alpha : Icons.sort),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadJadwalDosen,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: Text(
                            "Terjadi kesalahan:\n$errorMessage",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : filtered.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 40),
                        Center(
                          child: Text(
                            "Belum ada jadwal yang terdaftar.",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final mk = filtered[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailMatkulDosenPage(
                                  nama: mk.nama,
                                  ruangan: mk.ruangan,
                                  jam: mk.jam,
                                  // kalau nanti DetailMatkulDosenPage butuh jadwalId/hari tinggal tambahkan param
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
                                // TOP BLACK TITLE BAR
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
                                      mk.nama,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Hari     : ${mk.hari}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Ruangan : ${mk.ruangan}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Jam     : ${mk.jam}",
                                  style: const TextStyle(fontSize: 15),
                                ),
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
