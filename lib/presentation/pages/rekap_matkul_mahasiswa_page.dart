import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_appbar.dart';
import 'rekap_detail_matkul_mahasiswa_page.dart';

class RekapMatkulMahasiswaPage extends StatefulWidget {
  const RekapMatkulMahasiswaPage({super.key});

  @override
  _RekapMatkulMahasiswaPageState createState() =>
      _RekapMatkulMahasiswaPageState();
}

class _RekapMatkulMahasiswaPageState extends State<RekapMatkulMahasiswaPage> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  String? errorMessage;

  List<Map<String, dynamic>> dataMatkul = [];

  String searchQuery = "";
  bool ascending = true;

  @override
  void initState() {
    super.initState();
    loadMatkulMahasiswa();
  }

  Future<void> loadMatkulMahasiswa() async {
    try {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User tidak ditemukan");

      // 1. Ambil data mahasiswa
      final mhsRes = await supabase
          .from('mahasiswa')
          .select('id, kelas, prodi_id, semester')
          .eq('id_auth', user.id)
          .maybeSingle();

      if (mhsRes == null) throw Exception("Data mahasiswa tidak ditemukan");

      final String kelasMhs = mhsRes['kelas'];
      final int prodiId = mhsRes['prodi_id'];
      final int semesterMhs = mhsRes['semester'];

      // 2. Ambil JADWAL seperti di HomeMahasiswa
      final jadwalRes = await supabase
          .from('jadwal')
          .select('''
          id,
          matkul (
            id,
            nama_mk,
            prodi_id,
            semester
          ),
          kelas_mk (
            nama_kelas
          )
        ''')
          .eq('matkul.prodi_id', prodiId)
          .eq('matkul.semester', semesterMhs)
          .eq('kelas_mk.nama_kelas', kelasMhs);

      // 3. Hapus duplikat matkul (karena satu matkul bisa punya banyak jadwal)
      final seen = <String>{};
      final List<Map<String, dynamic>> hasil = [];

      for (var row in jadwalRes) {
        final mk = row['matkul'];

        if (mk == null || mk is! Map) continue;

        final nama = mk['nama_mk'] ?? "Tidak ada nama";

        if (!seen.contains(nama)) {
          seen.add(nama);
          hasil.add({
            "id": mk['id'],
            "matkul": {"nama_mk": nama},
          });
        }
      }

      setState(() {
        dataMatkul = hasil;
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
    // Filter berdasarkan search
    List filtered = dataMatkul.where((m) {
      final nama = m["matkul"]?["nama_mk"] ?? "";
      return nama.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    // Sort A-Z atau Z-A
    filtered.sort(
      (a, b) => ascending
          ? a["matkul"]["nama_mk"].compareTo(b["matkul"]["nama_mk"])
          : b["matkul"]["nama_mk"].compareTo(a["matkul"]["nama_mk"]),
    );

    return Scaffold(
      appBar: const CustomAppBar(role: "mhs"),

      body: Column(
        children: [
          const SizedBox(height: 10),

          const Text(
            "Rekap Presensi Mata Kuliah",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // ===== SEARCH BAR =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search",
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
                    onChanged: (v) => setState(() => searchQuery = v),
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
                ? Center(child: Text("Terjadi kesalahan:\n$errorMessage"))
                : filtered.isEmpty
                ? const Center(child: Text("Tidak ada matkul"))
                : RefreshIndicator(
                    onRefresh: loadMatkulMahasiswa,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final mkData = filtered[index];
                        final matkul = mkData['matkul'] ?? {};

                        final namaMatkul =
                            matkul['nama_mk'] ?? "Tidak ditemukan";
                        final totalPertemuan = 16;

                        // ❗ sementara 16, nanti bisa dihitung dari database absensi

                        return Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(
                              namaMatkul,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text("$totalPertemuan Pertemuan"),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailRekapMatkulPage(
                                    namaMatkul: namaMatkul,
                                    totalPertemuan: totalPertemuan,
                                  ),
                                ),
                              );
                            },
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
