import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAssignMatkulPage extends StatefulWidget {
  const AdminAssignMatkulPage({super.key});

  @override
  State<AdminAssignMatkulPage> createState() => _AdminAssignMatkulPageState();
}

class _AdminAssignMatkulPageState extends State<AdminAssignMatkulPage> {
  final supabase = Supabase.instance.client;

  // Data dari DB
  List<dynamic> prodiList = [];
  List<dynamic> matkulList = [];
  List<dynamic> dosenList = [];
  List<dynamic> ruanganList = [];

  // State pilihan
  int? selectedProdiId;
  int? selectedMatkulId;
  int? selectedDosenId;
  int? selectedRuanganId;
  String? selectedHari;

  // Kelas bisa banyak (A-E)
  final List<String> kelasOptions = ["A", "B", "C", "D", "E"];
  List<String> selectedKelasList = [];

  // Slot waktu (pakai index 0..8)
  int? startSlot;
  int? endSlot;

  bool isLoadingInitial = true;
  bool isLoadingMatkul = false;
  bool isLoadingDosen = false;
  bool isSaving = false;

  final List<Map<String, String>> slotWaktu = const [
    {"label": "1. 08.00 - 08.50", "start": "08:00", "end": "08:50"},
    {"label": "2. 08.50 - 09.40", "start": "08:50", "end": "09:40"},
    {"label": "3. 09.40 - 10.30", "start": "09:40", "end": "10:30"},
    {"label": "4. 10.30 - 11.20", "start": "10:30", "end": "11:20"},
    {"label": "5. 11.20 - 12.10", "start": "11:20", "end": "12:10"},
    {"label": "6. 13.00 - 13.50", "start": "13:00", "end": "13:50"},
    {"label": "7. 13.50 - 14.40", "start": "13:50", "end": "14:40"},
    {"label": "8. 14.40 - 15.30", "start": "14:40", "end": "15:30"},
    {"label": "9. 15.30 - 16.20", "start": "15:30", "end": "16:20"},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loadInitialData() async {
    try {
      final prodiRes = await supabase.from('prodi').select('id,nama');
      final ruanganRes = await supabase.from('ruangan').select('id,nama');

      setState(() {
        prodiList = prodiRes as List<dynamic>;
        ruanganList = ruanganRes as List<dynamic>;
        isLoadingInitial = false;
      });
    } catch (e) {
      _showMessage("Gagal load data awal: $e");
      setState(() => isLoadingInitial = false);
    }
  }

  Future<void> _loadMatkulByProdi(int prodiId) async {
    setState(() {
      isLoadingMatkul = true;
      matkulList = [];
      selectedMatkulId = null;
    });

    try {
      final data = await supabase
          .from('matkul')
          .select('id, kode_mk, nama_mk, semester, prodi_id')
          .eq('prodi_id', prodiId)
          .order('semester', ascending: true);

      setState(() {
        matkulList = data as List<dynamic>;
        isLoadingMatkul = false;
      });
    } catch (e) {
      _showMessage("Gagal load matkul: $e");
      setState(() => isLoadingMatkul = false);
    }
  }

  Future<void> _loadDosenByProdi(int prodiId) async {
    setState(() {
      isLoadingDosen = true;
      dosenList = [];
      selectedDosenId = null;
    });

    try {
      final result = await supabase
          .from('dosen_prodi')
          .select('dosen (id, nama)')
          .eq('prodi_id', prodiId);

      final list = <dynamic>[];
      for (final row in result as List<dynamic>) {
        if (row['dosen'] != null) list.add(row['dosen']);
      }

      setState(() {
        dosenList = list;
        isLoadingDosen = false;
      });
    } catch (e) {
      _showMessage("Gagal load dosen: $e");
      setState(() => isLoadingDosen = false);
    }
  }

  /// Ambil atau buat kelas_mk untuk mk_id & nama_kelas tertentu
  Future<int> _getOrCreateKelas(int mkId, String kelas) async {
    try {
      final cek = await supabase
          .from('kelas_mk')
          .select('id')
          .eq('mk_id', mkId)
          .eq('nama_kelas', kelas)
          .maybeSingle();

      if (cek != null) {
        return cek['id'] as int;
      }

      final insert = await supabase
          .from('kelas_mk')
          .insert({'mk_id': mkId, 'nama_kelas': kelas})
          .select('id')
          .single();

      return insert['id'] as int;
    } catch (e) {
      rethrow;
    }
  }

  // Dialog multi-select kelas A-E
  Future<void> _pickKelasDialog() async {
    final tempSelected = Set<String>.from(selectedKelasList);

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Pilih Kelas (bisa lebih dari satu)"),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: kelasOptions.map((k) {
                    final checked = tempSelected.contains(k);
                    return CheckboxListTile(
                      dense: true,
                      title: Text("Kelas $k"),
                      value: checked,
                      onChanged: (val) {
                        setStateDialog(() {
                          if (val == true) {
                            tempSelected.add(k);
                          } else {
                            tempSelected.remove(k);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedKelasList = tempSelected.toList()..sort();
                });
                Navigator.pop(ctx);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _simpan() async {
    if (selectedProdiId == null ||
        selectedMatkulId == null ||
        selectedDosenId == null ||
        selectedRuanganId == null ||
        selectedHari == null ||
        selectedKelasList.isEmpty ||
        startSlot == null ||
        endSlot == null) {
      _showMessage(
        "Harap isi semua field (termasuk pilih minimal satu kelas)!",
      );
      return;
    }

    if (endSlot! < startSlot!) {
      _showMessage("Slot akhir harus >= slot awal.");
      return;
    }

    final jamMulai = slotWaktu[startSlot!]['start']!;
    final jamSelesai = slotWaktu[endSlot!]['end']!;

    try {
      setState(() => isSaving = true);

      // Untuk setiap kelas yang dipilih (A, B, C, ...)
      for (final kelas in selectedKelasList) {
        // 1. pastikan kelas_mk ada
        final kelasId = await _getOrCreateKelas(selectedMatkulId!, kelas);

        // 2. insert jadwal untuk kelas tersebut
        await supabase.from('jadwal').insert({
          'matkul_id': selectedMatkulId,
          'dosen_id': selectedDosenId,
          'ruangan_id': selectedRuanganId,
          'hari': selectedHari,
          'jam_mulai': jamMulai,
          'jam_selesai': jamSelesai,
          'kelas_id': kelasId,
        });
      }

      setState(() => isSaving = false);
      _showMessage(
        "Jadwal berhasil ditambahkan untuk kelas: ${selectedKelasList.join(', ')}",
      );

      // reset pilihan (kecuali prodi agar bisa lanjut input)
      setState(() {
        selectedMatkulId = null;
        selectedDosenId = null;
        selectedRuanganId = null;
        selectedHari = null;
        startSlot = null;
        endSlot = null;
        selectedKelasList = [];
        matkulList = [];
        dosenList = [];
      });
    } catch (e) {
      setState(() => isSaving = false);
      _showMessage("Gagal menyimpan jadwal: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Matkul ke Dosen")),
      body: isLoadingInitial
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // PRODI
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Pilih Prodi",
                      ),
                      initialValue: selectedProdiId,
                      items: prodiList
                          .map(
                            (p) => DropdownMenuItem<int>(
                              value: p['id'] as int,
                              child: Text(p['nama'] as String),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          selectedProdiId = v;
                          selectedMatkulId = null;
                          selectedDosenId = null;
                          selectedKelasList = [];
                          matkulList = [];
                          dosenList = [];
                        });
                        _loadMatkulByProdi(v);
                        _loadDosenByProdi(v);
                      },
                    ),

                    const SizedBox(height: 16),

                    // MATKUL
                    isLoadingMatkul
                        ? const LinearProgressIndicator()
                        : DropdownButtonFormField<int>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: "Pilih Matkul",
                            ),
                            initialValue: selectedMatkulId,
                            items: matkulList.map((m) {
                              final semester = m['semester'] ?? '-';
                              return DropdownMenuItem<int>(
                                value: m['id'] as int,
                                child: Text(
                                  "(${m['kode_mk']}) ${m['nama_mk']} — Semester $semester",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (v) {
                              setState(() {
                                selectedMatkulId = v;
                                selectedKelasList = [];
                              });
                            },
                          ),

                    const SizedBox(height: 16),

                    // KELAS (multi)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Pilih Kelas",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: selectedMatkulId == null
                          ? null
                          : _pickKelasDialog,
                      child: const Text("Pilih Kelas (A–E)"),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        selectedKelasList.isEmpty
                            ? "Belum memilih kelas"
                            : "Dipilih: ${selectedKelasList.join(', ')}",
                        style: TextStyle(
                          fontSize: 13,
                          color: selectedKelasList.isEmpty
                              ? Colors.red
                              : Colors.green[700],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // DOSEN
                    isLoadingDosen
                        ? const LinearProgressIndicator()
                        : DropdownButtonFormField<int>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: "Pilih Dosen",
                            ),
                            initialValue: selectedDosenId,
                            items: dosenList
                                .map(
                                  (d) => DropdownMenuItem<int>(
                                    value: d['id'] as int,
                                    child: Text(d['nama'] as String),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => selectedDosenId = v),
                          ),

                    const SizedBox(height: 16),

                    // RUANGAN
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Pilih Ruangan",
                      ),
                      initialValue: selectedRuanganId,
                      items: ruanganList
                          .map(
                            (r) => DropdownMenuItem<int>(
                              value: r['id'] as int,
                              child: Text(r['nama'] as String),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedRuanganId = v),
                    ),

                    const SizedBox(height: 16),

                    // HARI
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Pilih Hari",
                      ),
                      initialValue: selectedHari,
                      items: ["Senin", "Selasa", "Rabu", "Kamis", "Jumat"]
                          .map(
                            (h) => DropdownMenuItem<String>(
                              value: h,
                              child: Text(h),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedHari = v),
                    ),

                    const SizedBox(height: 20),

                    // SLOT MULAI
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Slot Mulai",
                      ),
                      initialValue: startSlot,
                      items: List.generate(
                        slotWaktu.length,
                        (i) => DropdownMenuItem<int>(
                          value: i,
                          child: Text(slotWaktu[i]['label']!),
                        ),
                      ),
                      onChanged: (v) => setState(() => startSlot = v),
                    ),

                    const SizedBox(height: 16),

                    // SLOT AKHIR
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Slot Akhir",
                      ),
                      initialValue: endSlot,
                      items: List.generate(
                        slotWaktu.length,
                        (i) => DropdownMenuItem<int>(
                          value: i,
                          child: Text(slotWaktu[i]['label']!),
                        ),
                      ),
                      onChanged: (v) => setState(() => endSlot = v),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _simpan,
                        child: isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Simpan"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
