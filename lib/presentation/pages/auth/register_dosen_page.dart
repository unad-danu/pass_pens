import 'dart:math';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/create_dosen_page.dart';
import '../../widgets/custom_appbar.dart';

class RegisterDosenPage extends StatefulWidget {
  const RegisterDosenPage({super.key});

  @override
  State<RegisterDosenPage> createState() => _RegisterDosenPageState();
}

class _RegisterDosenPageState extends State<RegisterDosenPage>
    with TickerProviderStateMixin {
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _nipCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  List<String> selectedProdi = [];

  // PRODI DARI SUPABASE
  List<String> listProdi = [];
  bool _loadingProdi = true;
  String? _loadError;

  String? errNama;
  String? errNip;
  String? errProdi;
  String? errPhone;
  String? errEmail;

  // FETCH PRODI DARI SUPABASE
  Future<void> fetchProdi() async {
    try {
      final data = await Supabase.instance.client.from('prodi').select('nama');

      setState(() {
        listProdi = data.map<String>((p) => p['nama'] as String).toList();
        _loadingProdi = false;
      });
    } catch (e) {
      setState(() {
        _loadError = "Gagal memuat data prodi";
        _loadingProdi = false;
      });
    }
  }

  late final AnimationController _shakeFormController;
  late final AnimationController _shakeNamaController;
  late final AnimationController _shakeNipController;
  late final AnimationController _shakeProdiController;
  late final AnimationController _shakePhoneController;
  late final AnimationController _shakeEmailController;

  @override
  void initState() {
    super.initState();
    fetchProdi();

    _shakeFormController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeNamaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeNipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeProdiController = AnimationController(
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
    _nipCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _shakeFormController.dispose();
    _shakeNamaController.dispose();
    _shakeNipController.dispose();
    _shakeProdiController.dispose();
    _shakePhoneController.dispose();
    _shakeEmailController.dispose();
    super.dispose();
  }

  // ================= VALIDASI ==================

  final _emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  String? validateNama(String v) {
    if (v.trim().isEmpty) return "Nama wajib diisi";
    if (v.trim().length < 2) return "Nama terlalu pendek";
    return null;
  }

  String? validateNip(String v) {
    if (v.trim().isEmpty) return "NIP wajib diisi";
    if (!RegExp(r'^[0-9]+$').hasMatch(v)) return "NIP hanya angka";
    if (v.length < 6) return "NIP minimal 6 digit";
    return null;
  }

  String? validateProdi(List<String> v) {
    if (v.isEmpty) return "Pilih minimal 1 prodi";
    return null;
  }

  String? validatePhone(String v) {
    if (v.trim().isEmpty) return "Nomor telepon wajib diisi";
    if (!RegExp(r'^[0-9]+$').hasMatch(v.replaceAll('-', '')))
      return "Nomor telepon hanya angka";
    if (v.replaceAll('-', '').length < 8) return "Nomor telepon terlalu pendek";
    return null;
  }

  String? validateEmail(String v) {
    if (v.trim().isEmpty) return "E-mail wajib diisi";
    if (!_emailRegex.hasMatch(v.trim())) return "Format e-mail tidak valid";
    return null;
  }

  void _triggerShake(AnimationController c) => c.forward(from: 0);

  void _onSubmit() {
    final n = validateNama(_namaCtrl.text);
    final nip = validateNip(_nipCtrl.text);
    final p = validateProdi(selectedProdi);
    final ph = validatePhone(_phoneCtrl.text);
    final e = validateEmail(_emailCtrl.text);

    setState(() {
      errNama = n;
      errNip = nip;
      errProdi = p;
      errPhone = ph;
      errEmail = e;
    });

    if ([n, nip, p, ph, e].any((x) => x != null)) {
      if (n != null) _triggerShake(_shakeNamaController);
      if (nip != null) _triggerShake(_shakeNipController);
      if (p != null) _triggerShake(_shakeProdiController);
      if (ph != null) _triggerShake(_shakePhoneController);
      if (e != null) _triggerShake(_shakeEmailController);
      _triggerShake(_shakeFormController);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateDosenPage(
          biodata: {
            "nama": _namaCtrl.text.trim(),
            "nip": _nipCtrl.text.trim(),
            "phone": _phoneCtrl.text.trim(),
            "email_recovery": _emailCtrl.text.trim(),
            "prodi": selectedProdi,
          },
        ),
      ),
    );
  }

  InputDecoration fieldDeco(String label, String? err) {
    return InputDecoration(
      labelText: label,
      errorText: err,
      floatingLabelStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,

      appBar: const CustomAppBar(role: "guest", showBack: false),

      body: SafeArea(
        top: false,
        child: GestureDetector(
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
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            left: 24,
                            right: 24,
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 20,
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
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 22),

                                // ============ NAMA ============
                                AnimatedBuilder(
                                  animation: _shakeNamaController,
                                  builder: (context, child) {
                                    final offset =
                                        sin(_shakeNamaController.value * 6.28) *
                                        4;
                                    return Transform.translate(
                                      offset: Offset(offset, 0),
                                      child: child,
                                    );
                                  },
                                  child: TextField(
                                    controller: _namaCtrl,
                                    decoration:
                                        fieldDeco(
                                          "Nama Lengkap",
                                          errNama,
                                        ).copyWith(
                                          prefixIcon: const Icon(Icons.person),
                                        ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // ============ NIP ============
                                AnimatedBuilder(
                                  animation: _shakeNipController,
                                  builder: (context, child) {
                                    final offset =
                                        sin(_shakeNipController.value * 6.28) *
                                        4;
                                    return Transform.translate(
                                      offset: Offset(offset, 0),
                                      child: child,
                                    );
                                  },
                                  child: TextField(
                                    controller: _nipCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: fieldDeco("NIP", errNip)
                                        .copyWith(
                                          prefixIcon: const Icon(Icons.badge),
                                        ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // ============ PRODI ============
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
                                      child: child,
                                    );
                                  },
                                  child: _loadingProdi
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : _loadError != null
                                      ? Text(
                                          _loadError!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () async {
                                            final results =
                                                await showDialog<List<String>>(
                                                  context: context,
                                                  builder: (context) {
                                                    return MultiSelectDialog(
                                                      items: listProdi
                                                          .map(
                                                            (p) =>
                                                                MultiSelectItem(
                                                                  p,
                                                                  p,
                                                                ),
                                                          )
                                                          .toList(),
                                                      initialValue:
                                                          selectedProdi,
                                                      confirmText: const Text(
                                                        "OK",
                                                      ),
                                                      cancelText: const Text(
                                                        "Batal",
                                                      ),
                                                    );
                                                  },
                                                );

                                            if (results != null) {
                                              setState(() {
                                                selectedProdi = results;
                                              });
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: InputDecoration(
                                              labelText: "Prodi yang Diajar",
                                              errorText: errProdi,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.school_outlined,
                                              ),
                                            ),
                                            child: Text(
                                              selectedProdi.isEmpty
                                                  ? ""
                                                  : selectedProdi.join(", "),
                                            ),
                                          ),
                                        ),
                                ),

                                const SizedBox(height: 20),

                                // ============ PHONE ============
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
                                      child: child,
                                    );
                                  },
                                  child: TextField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    decoration:
                                        fieldDeco(
                                          "Phone Number",
                                          errPhone,
                                        ).copyWith(
                                          prefixIcon: const Icon(Icons.phone),
                                        ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // ============ EMAIL ============
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
                                      child: child,
                                    );
                                  },
                                  child: TextField(
                                    controller: _emailCtrl,
                                    decoration:
                                        fieldDeco(
                                          "Recovery Email",
                                          errEmail,
                                        ).copyWith(
                                          prefixIcon: const Icon(Icons.email),
                                        ),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // CONTINUE BUTTON
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

                      // FOOTER
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        width: double.infinity,
                        color: const Color(0xFF0D4C73),
                        child: const Text(
                          "Electronic Engineering\nPolytechnic Institute of Surabaya",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
