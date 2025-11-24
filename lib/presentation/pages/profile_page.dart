import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? userData; // data mahasiswa & dosen
  List<String> prodiList = []; // khusus dosen
  bool isLoading = true;
  String role = ""; // mhs / dsn

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return;

    // ==============================
    // 1. Ambil role user dari tabel users
    // ==============================
    final userRow = await supabase
        .from('users')
        .select('id, role')
        .eq('id_auth', authUser.id)
        .maybeSingle();

    if (userRow == null) {
      setState(() => isLoading = false);
      return;
    }

    final int userId = userRow['id'];
    role = userRow['role'];

    // ==============================
    // 2. Jika MAHASISWA
    // ==============================
    if (role == "mhs") {
      final res = await supabase
          .from('mahasiswa')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      setState(() {
        userData = res;
        prodiList = []; // mahasiswa tidak perlu list prodi
        isLoading = false;
      });
      return;
    }

    // ==============================
    // 3. Jika DOSEN → Ambil relasi prodi
    // ==============================
    if (role == "dsn") {
      final res = await supabase
          .from('dosen')
          .select('''
            id,
            nama,
            email,
            phone,
            nip,
            email_recovery,
            dosen_prodi (
              prodi ( nama )
            )
          ''')
          .eq('user_id', userId)
          .single();

      final List<String> list = (res['dosen_prodi'] as List)
          .map((dp) => dp['prodi']['nama'] as String)
          .toList();

      setState(() {
        userData = res;
        prodiList = list;
        isLoading = false;
      });
      return;
    }
  }

  // ==============================
  // Fungsi untuk cari kelas mahasiswa
  // ==============================
  String getKelas(String nrp) {
    if (nrp.length < 3) return "-";
    int last = int.tryParse(nrp.substring(nrp.length - 3)) ?? 0;

    if (last >= 1 && last <= 30) return "A";
    if (last >= 31 && last <= 60) return "B";
    if (last >= 61 && last <= 90) return "C";
    if (last >= 91 && last <= 120) return "D";
    return "E";
  }

  void _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  Widget buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title :", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = userData;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B5E86),
        elevation: 2,
        title: const Column(
          children: [
            Text(
              "PASS",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "PENS Attendance Smart System",
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
        toolbarHeight: 70,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? const Center(child: Text("Data tidak ditemukan"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= PROFILE HEADER =================
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['nama'] ?? "-",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data['email'] ?? "-",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ================= DATA MAHASISWA =================
                  if (role == "mhs") ...[
                    buildItem("Nama Lengkap", data['nama']),
                    buildItem("NRP", data['nrp']),
                    buildItem("Kelas", getKelas(data['nrp'])),
                    buildItem("Prodi", data['prodi']),
                    buildItem("Angkatan", "${data['angkatan']}"),
                    buildItem("Nomor Telepon", data['phone']),
                    buildItem("Recovery Email", data['email_recovery']),
                  ],

                  // ================= DATA DOSEN =================
                  if (role == "dsn") ...[
                    buildItem("NIP", data['nip'] ?? "-"),
                    buildItem("Nama", data['nama'] ?? "-"),
                    buildItem("Nomor Telepon", data['phone'] ?? "-"),
                    buildItem("Recovery Email", data['email_recovery'] ?? "-"),

                    const SizedBox(height: 10),
                    const Text(
                      "Prodi yang Diajar:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 8,
                      children: prodiList
                          .map((p) => Chip(label: Text(p)))
                          .toList(),
                    ),

                    const SizedBox(height: 20),
                  ],

                  const SizedBox(height: 35),

                  // ================= LOGOUT =================
                  Center(
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Log Out",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
