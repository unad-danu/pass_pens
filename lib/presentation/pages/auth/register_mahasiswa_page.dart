import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/create_mahasiswa_page.dart';

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
      prefixIcon: Icon(icon),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  void onSubmit() {
    setState(() {
      errNama = namaC.text.isEmpty ? "Nama wajib diisi" : null;
      errNrp = nrpC.text.isEmpty ? "NRP wajib diisi" : null;
      errProdi = selectedProdi == null ? "Prodi wajib dipilih" : null;
      errAngkatan = selectedAngkatan == null ? "Angkatan wajib dipilih" : null;
      errTelp = telpC.text.isEmpty ? "Nomor telepon wajib diisi" : null;
      errRecovery = recoveryC.text.isEmpty
          ? "Email pemulihan wajib diisi"
          : null;
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
      "email_recovery": recoveryC.text.trim(),
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
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,

      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 22),
                width: double.infinity,
                color: const Color(0xFF0D4C73),
                child: const Column(
                  children: [
                    Text(
                      "PASS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "PENS Attendance Smart System",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: shaker(
                    shakeMain,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 20),
                          label: const Text("", style: TextStyle(fontSize: 15)),
                        ),
                        const Center(
                          child: Text(
                            "Enter Your Biodata",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        shaker(
                          shakeNama,
                          TextField(
                            controller: namaC,
                            decoration: deco(
                              "Nama Lengkap",
                              errNama,
                              Icons.person,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        shaker(
                          shakeNrp,
                          TextField(
                            controller: nrpC,
                            keyboardType: TextInputType.number,
                            decoration: deco("NRP", errNrp, Icons.badge),
                          ),
                        ),
                        const SizedBox(height: 18),

                        shaker(
                          shakeProdi,
                          loadingProdi
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  hint: const Text(
                                    "Pilih Prodi",
                                  ), // placeholder
                                  decoration: deco(
                                    "Prodi",
                                    errProdi,
                                    Icons.school,
                                  ),
                                  value:
                                      selectedProdi, // null awal -> placeholder tampil
                                  items: listProdi.map((p) {
                                    return DropdownMenuItem(
                                      value: p,
                                      child: Text(
                                        p,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (v) =>
                                      setState(() => selectedProdi = v),
                                ),
                        ),
                        const SizedBox(height: 18),

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
                            onChanged: (v) =>
                                setState(() => selectedAngkatan = v),
                          ),
                        ),
                        const SizedBox(height: 18),

                        shaker(
                          shakeTelp,
                          TextField(
                            controller: telpC,
                            keyboardType: TextInputType.phone,
                            decoration: deco(
                              "Nomor Telepon",
                              errTelp,
                              Icons.phone,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

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
              ),
            ],
          ),
        ),
      ),

      // 🚀 Footer kini ikut naik saat keyboard muncul
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        color: const Color(0xFF0D4C73),
        child: const SafeArea(
          top: false,
          child: Text(
            "Electronic Engineering\nPolytechnic Institute of Surabaya",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
