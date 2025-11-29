import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/create_mahasiswa_page.dart';
import '../../widgets/custom_appbar.dart';

class RegisterMahasiswa extends StatefulWidget {
  const RegisterMahasiswa({super.key});

  @override
  State<RegisterMahasiswa> createState() => _RegisterMahasiswaState();
}

class _RegisterMahasiswaState extends State<RegisterMahasiswa>
    with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  final namaC = TextEditingController();
  final nrpC = TextEditingController();
  final telpC = TextEditingController();
  final recoveryC = TextEditingController();

  String? selectedProdi;
  String? selectedAngkatan;

  List<String> listProdi = [];
  List<String> listAngkatan = [];
  bool loadingProdi = false;

  String? errNama;
  String? errNrp;
  String? errProdi;
  String? errAngkatan;
  String? errTelp;
  String? errRecovery;

  AnimationController? shakeMain;
  AnimationController? shakeNama;
  AnimationController? shakeNrp;
  AnimationController? shakeProdi;
  AnimationController? shakeAngkatan;
  AnimationController? shakeTelp;
  AnimationController? shakeRecovery;

  @override
  void initState() {
    super.initState();
    _generateAngkatan();
    _loadProdi();

    shakeMain = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    shakeNama = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    shakeNrp = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    shakeProdi = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    shakeAngkatan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    shakeTelp = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    shakeRecovery = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    namaC.dispose();
    nrpC.dispose();
    telpC.dispose();
    recoveryC.dispose();
    shakeMain?.dispose();
    shakeNama?.dispose();
    shakeNrp?.dispose();
    shakeProdi?.dispose();
    shakeAngkatan?.dispose();
    shakeTelp?.dispose();
    shakeRecovery?.dispose();
    super.dispose();
  }

  void _generateAngkatan() {
    int t = DateTime.now().year;
    listAngkatan = List.generate(8, (i) => (t - i).toString());
  }

  Future<void> _loadProdi() async {
    try {
      setState(() => loadingProdi = true);

      final data = await supabase.from('prodi').select('id, nama');
      print("HASIL PRODI: $data");

      setState(() {
        listProdi = (data as List)
            .map<String>((e) => e['nama'] as String)
            .toList();
      });
    } catch (e) {
      print("ERROR LOAD PRODI: $e");
    } finally {
      if (mounted) setState(() => loadingProdi = false);
    }
  }

  void triggerShake(AnimationController? c) => c?.forward(from: 0);

  InputDecoration deco(String label, String? err, IconData icon) {
    return InputDecoration(
      labelText: label,
      errorText: err,
      // Biar errorText bisa wrap / turun ke baris bawah
      errorMaxLines: 3,
      errorStyle: const TextStyle(fontSize: 13, height: 1.2, color: Colors.red),
      prefixIcon: Icon(icon),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  // --- Validator Gmail ---
  bool isValidGmail(String email) {
    // regex memastikan format lokal-part yang valid + @gmail.com
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    return regex.hasMatch(email);
  }

  void onSubmit() {
    // ambil dan trim terlebih dahulu (jangan langsung lowercasing saat validasi, tapi simpan lower saat pass ke biodata)
    final recoveryRaw = recoveryC.text.trim();

    setState(() {
      errNama = namaC.text.isEmpty ? "Nama wajib diisi" : null;
      errNrp = nrpC.text.isEmpty ? "NRP wajib diisi" : null;
      errProdi = selectedProdi == null ? "Prodi wajib dipilih" : null;
      errAngkatan = selectedAngkatan == null ? "Angkatan wajib dipilih" : null;
      errTelp = telpC.text.isEmpty ? "Nomor telepon wajib diisi" : null;

      if (recoveryRaw.isEmpty) {
        errRecovery = "Email pemulihan wajib diisi";
      } else if (!isValidGmail(recoveryRaw)) {
        // teks error yang lebih ramah untuk wrapping
        errRecovery =
            "Gunakan E-mail Gmail yang valid (contoh: users@gmail.com)";
      } else {
        errRecovery = null;
      }
    });

    if ([
      errNama,
      errNrp,
      errProdi,
      errAngkatan,
      errTelp,
      errRecovery,
    ].any((e) => e != null)) {
      if (errNama != null) triggerShake(shakeNama);
      if (errNrp != null) triggerShake(shakeNrp);
      if (errProdi != null) triggerShake(shakeProdi);
      if (errAngkatan != null) triggerShake(shakeAngkatan);
      if (errTelp != null) triggerShake(shakeTelp);
      if (errRecovery != null) triggerShake(shakeRecovery);
      triggerShake(shakeMain);
      return;
    }

    final biodata = {
      "nama": namaC.text.trim(),
      "nrp": nrpC.text.trim(),
      "prodi": selectedProdi,
      "angkatan": selectedAngkatan,
      "phone": telpC.text.trim(),
      // simpan email recovery dalam lowercase agar konsisten
      "email_recovery": recoveryRaw.toLowerCase(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateMahasiswaPage(biodata: biodata)),
    );
  }

  Widget shaker(AnimationController? c, Widget child) {
    if (c == null) return child;
    return AnimatedBuilder(
      animation: c,
      builder: (_, child) {
        double offset = sin(c.value * 6.28) * 4;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,

      appBar: const CustomAppBar(role: "mhs"),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: shaker(
          shakeMain,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol back di body
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black, // ← warna hitam
                ),
                label: const Text(""),
              ),

              const Center(
                child: Text(
                  "Enter Your Biodata",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // Nama
              shaker(
                shakeNama,
                TextField(
                  controller: namaC,
                  decoration: deco("Nama Lengkap", errNama, Icons.person),
                ),
              ),
              const SizedBox(height: 18),

              // NRP
              shaker(
                shakeNrp,
                TextField(
                  controller: nrpC,
                  keyboardType: TextInputType.number,
                  decoration: deco("NRP", errNrp, Icons.badge),
                ),
              ),
              const SizedBox(height: 18),

              // Prodi
              shaker(
                shakeProdi,
                loadingProdi
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: deco("Prodi", errProdi, Icons.school),
                        value: selectedProdi,
                        items: listProdi.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => selectedProdi = v),
                      ),
              ),
              const SizedBox(height: 18),

              // Angkatan
              shaker(
                shakeAngkatan,
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: deco(
                    "Angkatan",
                    errAngkatan,
                    Icons.calendar_month,
                  ),
                  value: selectedAngkatan,
                  items: listAngkatan.map((y) {
                    return DropdownMenuItem(value: y, child: Text(y));
                  }).toList(),
                  onChanged: (v) => setState(() => selectedAngkatan = v),
                ),
              ),
              const SizedBox(height: 18),

              // Telepon
              shaker(
                shakeTelp,
                TextField(
                  controller: telpC,
                  keyboardType: TextInputType.phone,
                  decoration: deco("Nomor Telepon", errTelp, Icons.phone),
                ),
              ),
              const SizedBox(height: 18),

              // Email recovery
              shaker(
                shakeRecovery,
                TextField(
                  controller: recoveryC,
                  decoration: deco(
                    "E-mail Pemulihan",
                    errRecovery,
                    Icons.email,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),

              const SizedBox(height: 30),

              // Tombol Continue
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: onSubmit,
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        width: double.infinity,
        color: const Color(0xFF0D4C73),
        child: const SafeArea(
          top: false,
          child: Text(
            "Electronic Engineering\nPolytechnic Institute of Surabaya",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
