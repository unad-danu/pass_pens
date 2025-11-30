import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAssignMatkulPage extends StatefulWidget {
  const AdminAssignMatkulPage({super.key});

  @override
  State<AdminAssignMatkulPage> createState() => _AdminAssignMatkulPageState();
}

class _AdminAssignMatkulPageState extends State<AdminAssignMatkulPage> {
  final supabase = Supabase.instance.client;

  int? selectedDosen;
  int? selectedMatkul;
  int? selectedRuang;
  String? selectedHari;

  TimeOfDay? jamMulai;
  TimeOfDay? jamSelesai;

  List<dynamic> dosen = [];
  List<dynamic> matkul = [];
  List<dynamic> ruang = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    final d = await supabase.from('dosen').select();
    final m = await supabase.from('matkul').select();
    final r = await supabase.from('ruang').select();

    setState(() {
      dosen = d;
      matkul = m;
      ruang = r;
    });
  }

  Future assign() async {
    if (selectedDosen == null ||
        selectedMatkul == null ||
        selectedRuang == null ||
        selectedHari == null ||
        jamMulai == null ||
        jamSelesai == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua data harus diisi")));
      return;
    }

    // 1. buat kelas mk
    final kelas = await supabase
        .from('kelas_mk')
        .insert({
          'mk_id': selectedMatkul,
          'dsn_id': selectedDosen,
          'nama_kelas': "Kelas ${DateTime.now().millisecondsSinceEpoch}",
        })
        .select()
        .single();

    // 2. buat jadwal
    await supabase.from('jadwal').insert({
      'kelas_id': kelas['id'],
      'hari': selectedHari,
      'jam_mulai': "${jamMulai!.hour}:${jamMulai!.minute}",
      'jam_selesai': "${jamSelesai!.hour}:${jamSelesai!.minute}",
      'ruang_id': selectedRuang,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Berhasil assign matkul ke dosen")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Matkul ke Dosen")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Pilih Dosen"),
            DropdownButton<int>(
              value: selectedDosen,
              items: dosen
                  .map<DropdownMenuItem<int>>(
                    (e) => DropdownMenuItem(
                      value: e['id'],
                      child: Text(e['nama'] ?? "-"),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedDosen = v),
            ),

            const SizedBox(height: 20),
            const Text("Pilih Mata Kuliah"),
            DropdownButton<int>(
              value: selectedMatkul,
              items: matkul
                  .map<DropdownMenuItem<int>>(
                    (e) => DropdownMenuItem(
                      value: e['id'],
                      child: Text(e['nama_mk']),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedMatkul = v),
            ),

            const SizedBox(height: 20),
            const Text("Pilih Ruang"),
            DropdownButton<int>(
              value: selectedRuang,
              items: ruang
                  .map<DropdownMenuItem<int>>(
                    (e) => DropdownMenuItem(
                      value: e['id'],
                      child: Text(e['kode_ruang']),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedRuang = v),
            ),

            const SizedBox(height: 20),
            const Text("Pilih Hari"),
            DropdownButton<String>(
              value: selectedHari,
              items: [
                "Senin",
                "Selasa",
                "Rabu",
                "Kamis",
                "Jumat",
                "Sabtu",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => selectedHari = v),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              child: Text(
                jamMulai == null
                    ? "Pilih Jam Mulai"
                    : "Mulai: ${jamMulai!.format(context)}",
              ),
              onPressed: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (t != null) setState(() => jamMulai = t);
              },
            ),

            ElevatedButton(
              child: Text(
                jamSelesai == null
                    ? "Pilih Jam Selesai"
                    : "Selesai: ${jamSelesai!.format(context)}",
              ),
              onPressed: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (t != null) setState(() => jamSelesai = t);
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(onPressed: assign, child: const Text("Simpan")),
          ],
        ),
      ),
    );
  }
}
