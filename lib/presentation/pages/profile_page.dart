import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return;

    // 1. Cari user_id integer dari tabel users
    final userRow = await supabase
        .from('users')
        .select('id')
        .eq('id_auth', authUser.id)
        .maybeSingle();

    if (userRow == null) {
      setState(() => isLoading = false);
      return;
    }

    final int userId = userRow['id'];

    // 2. Ambil data mahasiswa pakai user_id
    final response = await supabase
        .from('mahasiswa')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (!mounted) return;

    setState(() {
      userData = response;
      isLoading = false;
    });
  }

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
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                  /// PROFILE HEADER
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

                  /// INFORMASI DETAIL
                  buildItem("Nama Lengkap", data['nama'] ?? "-"),
                  buildItem("NRP", data['nrp'] ?? "-"),
                  buildItem("Kelas", getKelas(data['nrp'] ?? "")),
                  buildItem("Prodi", data['prodi'] ?? "-"),
                  buildItem("Angkatan", "${data['angkatan'] ?? '-'}"),
                  buildItem("Nomor Telepon", data['phone'] ?? "-"),
                  buildItem("Recovery E-mail", data['email_recovery'] ?? "-"),

                  const SizedBox(height: 35),

                  /// LOGOUT BUTTON
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
