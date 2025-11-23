import 'dart:math';
import 'package:flutter/material.dart';

class RegisterMahasiswaPage extends StatefulWidget {
  const RegisterMahasiswaPage({super.key});

  @override
  State<RegisterMahasiswaPage> createState() => _RegisterMahasiswaPageState();
}

class _RegisterMahasiswaPageState extends State<RegisterMahasiswaPage>
    with TickerProviderStateMixin {
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _nrpCtrl = TextEditingController();
  final TextEditingController _angkatanCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  String? selectedProdi;

  String? errNama;
  String? errNrp;
  String? errProdi;
  String? errAngkatan;
  String? errPhone;
  String? errEmail;

  final List<String> listProdi = [
    "D3 Teknik Informatika",
    "D4 Teknik Informatika",
    "D4 Teknik Komputer",
    "D4 Sains Data Terapan",
    "D4 Teknologi Rekayasa Multimedia",
    "D4 Teknologi Rekayasa Internet",
    "D3 Multimedia Broadcasting",
    "D4 Teknologi Game",
    "D3 Teknik Elektronika Industri",
    "D4 Teknik Elektronika Industri",
    "D3 Teknik Elektronika",
    "D4 Teknik Elektronika",
    "D4 Teknik Mekatronika",
    "D4 Sistem Pembangkit Energi",
    "D3 Teknik Telekomunikasi",
    "D4 Teknik Telekomunikasi",
  ];

  late final AnimationController _shakeFormController;
  late final AnimationController _shakeNamaController;
  late final AnimationController _shakeNrpController;
  late final AnimationController _shakeProdiController;
  late final AnimationController _shakeAngkatanController;
  late final AnimationController _shakePhoneController;
  late final AnimationController _shakeEmailController;

  @override
  void initState() {
    super.initState();
    _shakeFormController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeNamaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeNrpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeProdiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeAngkatanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakePhoneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeEmailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nrpCtrl.dispose();
    _angkatanCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();

    _shakeFormController.dispose();
    _shakeNamaController.dispose();
    _shakeNrpController.dispose();
    _shakeProdiController.dispose();
    _shakeAngkatanController.dispose();
    _shakePhoneController.dispose();
    _shakeEmailController.dispose();

    super.dispose();
  }

  final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  String? validateNama(String v) {
    if (v.trim().isEmpty) return "Nama wajib diisi";
    if (v.trim().length < 2) return "Nama terlalu pendek";
    return null;
  }

  String? validateNrp(String v) {
    if (v.trim().isEmpty) return "NRP wajib diisi";
    if (!RegExp(r'^[0-9]+$').hasMatch(v.trim())) return "NRP hanya angka";
    if (v.trim().length < 10 || v.trim().length > 14) return "NRP 10–14 digit";
    return null;
  }

  String? validateProdi(String? v) {
    if (v == null || v.isEmpty) return "Pilih prodi";
    return null;
  }

  String? validateAngkatan(String v) {
    if (v.trim().isEmpty) return "Angkatan wajib diisi";
    if (!RegExp(r'^[0-9]+$').hasMatch(v.trim())) return "Angkatan hanya angka";
    if (v.trim().length != 4) return "Format angkatan: 2024";
    return null;
  }

  String? validatePhone(String v) {
    if (v.trim().isEmpty) return "Nomor telepon wajib diisi";
    if (!RegExp(r'^[0-9]+$').hasMatch(v.replaceAll('-', '').trim())) {
      return "Nomor telepon hanya angka";
    }
    if (v.replaceAll('-', '').trim().length < 8) {
      return "Nomor telepon terlalu pendek";
    }
    return null;
  }

  String? validateEmail(String v) {
    if (v.trim().isEmpty) return "E-mail wajib diisi";
    if (!_emailRegex.hasMatch(v.trim())) return "Format e-mail tidak valid";
    return null;
  }

  void _triggerShake(AnimationController c) {
    c.forward(from: 0);
  }

  void _onSubmit() {
    final n = validateNama(_namaCtrl.text);
    final nrp = validateNrp(_nrpCtrl.text);
    final p = validateProdi(selectedProdi);
    final a = validateAngkatan(_angkatanCtrl.text);
    final ph = validatePhone(_phoneCtrl.text);
    final e = validateEmail(_emailCtrl.text);

    setState(() {
      errNama = n;
      errNrp = nrp;
      errProdi = p;
      errAngkatan = a;
      errPhone = ph;
      errEmail = e;
    });

    if ([n, nrp, p, a, ph, e].any((x) => x != null)) {
      if (n != null) _triggerShake(_shakeNamaController);
      if (nrp != null) _triggerShake(_shakeNrpController);
      if (p != null) _triggerShake(_shakeProdiController);
      if (a != null) _triggerShake(_shakeAngkatanController);
      if (ph != null) _triggerShake(_shakePhoneController);
      if (e != null) _triggerShake(_shakeEmailController);

      _triggerShake(_shakeFormController);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registrasi mahasiswa berhasil (demo)")),
    );
  }

  InputDecoration fieldDeco(String label, String? err, IconData icon) {
    return InputDecoration(
      labelText: label,
      floatingLabelStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
      errorText: err,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth > 500
                  ? 500.0
                  : constraints.maxWidth;

              return Center(
                child: SizedBox(
                  width: maxWidth,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        width: double.infinity,
                        color: const Color(0xFF0D4C73),
                        child: Column(
                          children: const [
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
                          padding: EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 8,
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 24,
                          ),
                          child: AnimatedBuilder(
                            animation: _shakeFormController,
                            builder: (context, child) {
                              final offset =
                                  sin(_shakeFormController.value * 6.28) * 6;
                              return Transform.translate(
                                offset: Offset(offset, 0),
                                child: child,
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      size: 20,
                                    ),
                                    label: const Text(
                                      "Back",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),

                                Center(
                                  child: Text(
                                    "Enter Your Biodata",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 22),

                                // ======= NAMA =======
                                AnimatedBuilder(
                                  animation: _shakeNamaController,
                                  builder: (context, child) {
                                    final offset =
                                        sin(_shakeNamaController.value * 6.28) *
                                        4;
                                    return Transform.translate(
                                      offset: Offset(offset, 0),
                                      child: TextField(
                                        controller: _namaCtrl,
                                        decoration: fieldDeco(
                                          "Nama Lengkap",
                                          errNama,
                                          Icons.person,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // ======= NRP =======
                                AnimatedBuilder(
                                  animation: _shakeNrpController,
                                  builder: (context, child) {
                                    final offset =
                                        sin(_shakeNrpController.value * 6.28) *
                                        4;
                                    return Transform.translate(
                                      offset: Offset(offset, 0),
                                      child: TextField(
                                        controller: _nrpCtrl,
                                        keyboardType: TextInputType.number,
                                        decoration: fieldDeco(
                                          "NRP",
                                          errNrp,
                                          Icons.badge,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // ======= PRODI =======
                                AnimatedBuilder(
                                  animation: _shakeProdiController,
                                  builder: (context, child) {
                                    final offset =
                                        sin(
                                          _shakeProdiController.value * 6.28,
                                        ) *
                                        4;
                                    return Transform.translate(
                                      offset: Offset(offset, 0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          final results =
                                              await showDialog<String>(
                                                context: context,
                                                builder: (context) {
                                                  return SimpleDialog(
                                                    title: const Text(
                                                      "Pilih Prodi",
                                                    ),
                                                    children: listProdi
                                                        .map(
                                                          (
                                                            p,
                                                          ) => SimpleDialogOption(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  context,
                                                                  p,
                                                                ),
                                                            child: Text(p),
                                                          ),
                                                        )
                                                        .toList(),
                                                  );
                                                },
                                              );

                                          if (results != null) {
                                            setState(
                                              () => selectedProdi = results,
                                            );
                                          }
                                        },
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: "Prodi",
                                            floatingLabelBehavior:
                                                selectedProdi == null
                                                ? FloatingLabelBehavior.auto
                                                : FloatingLabelBehavior.always,
                                            prefixIcon: const Icon(
                                              Icons.school,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.blue,
                                                    width: 2,
                                                  ),
                                                ),
                                            errorText: errProdi,
                                          ),
                                          isEmpty: selectedProdi == null,
                                          child: Text(
                                            selectedProdi ?? "",
                                            style: TextStyle(
                                              color: selectedProdi == null
                                                  ? Colors.transparent
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // ======= ANGKATAN =======
                                AnimatedBuilder(
                                  animation: _shakeAngkatanController,
                                  builder: (context, child) {
                                    final offset =
                                        sin(
                                          _shakeAngkatanController.value * 6.28,
                                        ) *
                                        4;
                                    return Transform.translate(
                                      offset: Offset(offset, 0),
                                      child: TextField(
                                        controller: _angkatanCtrl,
                                        keyboardType: TextInputType.number,
                                        decoration: fieldDeco(
                                          "Angkatan",
                                          errAngkatan,
                                          Icons.calendar_today,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // ======= PHONE =======
                                AnimatedBuilder(
                                  animation: _shakePhoneController,
                                  builder: (context, child) {
                                    final offset =
                                        sin(
                                          _shakePhoneController.value * 6.28,
                                        ) *
                                        4;
                                    return Transform.translate(
                                      offset: Offset(offset, 0),
                                      child: TextField(
                                        controller: _phoneCtrl,
                                        keyboardType: TextInputType.phone,
                                        decoration: fieldDeco(
                                          "Nomor Telepon",
                                          errPhone,
                                          Icons.phone,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // ======= EMAIL =======
                                AnimatedBuilder(
                                  animation: _shakeEmailController,
                                  builder: (context, child) {
                                    final offset =
                                        sin(
                                          _shakeEmailController.value * 6.28,
                                        ) *
                                        4;
                                    return Transform.translate(
                                      offset: Offset(offset, 0),
                                      child: TextField(
                                        controller: _emailCtrl,
                                        decoration: fieldDeco(
                                          "Recovery Email",
                                          errEmail,
                                          Icons.email,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 30),

                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                    ),
                                    onPressed: _onSubmit,
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

                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        width: double.infinity,
                        color: const Color(0xFF0D4C73),
                        child: const Text(
                          "Electronic Engineering\nPolytechnic Institute of Surabaya",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
