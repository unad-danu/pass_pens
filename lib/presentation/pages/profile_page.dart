import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_appbar.dart';

class ProfilePage extends StatefulWidget {
  final String? role;

  const ProfilePage({super.key, this.role});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? userData;
  List<String> prodiList = [];
  bool isLoading = true;

  String role = "";

  @override
  void initState() {
    super.initState();
    role = widget.role ?? ""; // FIX ERROR
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return;

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
    role = userRow['role'] ?? "";

    // =============================
    // DATA MAHASISWA
    // =============================
    if (role == "mhs") {
      final res = await supabase
          .from('mahasiswa')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      setState(() {
        userData = res;
        prodiList = [];
        isLoading = false;
      });
      return;
    }

    // =============================
    // DATA DOSEN
    // =============================
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
          .maybeSingle(); // FIX: ganti .single() → .maybeSingle()

      final list =
          (res?['dosen_prodi'] as List?)
              ?.map((dp) => dp['prodi']['nama'] as String)
              .toList() ??
          [];

      setState(() {
        userData = res;
        prodiList = list;
        isLoading = false;
      });
    }
  }

  // Tentukan kelas dari NRP mahasiswa
  String getKelas(String nrp) {
    if (nrp.length < 3) return "-";
    int last = int.tryParse(nrp.substring(nrp.length - 3)) ?? 0;

    if (last >= 1 && last <= 30) return "A";
    if (last >= 31 && last <= 60) return "B";
    if (last >= 61 && last <= 90) return "C";
    if (last >= 91 && last <= 120) return "D";
    return "E";
  }

  // LOGOUT
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

      appBar: CustomAppBar(role: role, showBack: false),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? const Center(child: Text("Data tidak ditemukan"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                      Expanded(
                        // <-- TAMBAHKAN INI
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['nama'] ?? "-",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2, // <-- CEGAH OVERFLOW
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              data['email'] ?? "-",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              maxLines: 1, // <-- EMAIL PANJANG JUGA AMAN
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ======================
                  // DATA MAHASISWA
                  // ======================
                  if (role == "mhs") ...[
                    buildItem("Nama Lengkap", data['nama'] ?? "-"),
                    buildItem("NRP", data['nrp'] ?? "-"),
                    buildItem("Kelas", getKelas(data['nrp'] ?? "00001")),
                    buildItem("Prodi", data['prodi'] ?? "-"),
                    buildItem("Angkatan", "${data['angkatan'] ?? "-"}"),
                    buildItem("Nomor Telepon", data['phone'] ?? "-"),
                    buildItem("Recovery Email", data['email_recovery'] ?? "-"),
                  ],

                  if (role == "dsn") ...[
                    buildItem("NIP", data['nip'] ?? "-"),
                    buildItem("Nama", data['nama'] ?? "-"),

                    // ===========================
                    //     PRODI LIST DOSEN
                    // ===========================
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Prodi yang Diajar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),

                        if (prodiList.isNotEmpty) ...[
                          ...prodiList.map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                "- $p",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ] else
                          const Text("-", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Divider(height: 1, color: Colors.grey.shade400),
                    const SizedBox(height: 12),

                    buildItem("Nomor Telepon", data['phone'] ?? "-"),
                    buildItem("Recovery Email", data['email_recovery'] ?? "-"),

                    const SizedBox(height: 20),
                  ],

                  const SizedBox(height: 35),

                  Center(
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
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
