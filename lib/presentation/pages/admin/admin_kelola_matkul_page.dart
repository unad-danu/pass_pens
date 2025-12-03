import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminKelolaMatkulPage extends StatefulWidget {
  const AdminKelolaMatkulPage({super.key});

  @override
  State<AdminKelolaMatkulPage> createState() => _AdminKelolaMatkulPageState();
}

class _AdminKelolaMatkulPageState extends State<AdminKelolaMatkulPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController searchC = TextEditingController();

  List<dynamic> matkulList = [];
  List<dynamic> prodiList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    await Future.wait([fetchMatkul(), fetchProdi()]);
  }

  Future<void> fetchProdi() async {
    final res = await supabase.from('prodi').select('id, nama').order('nama');
    setState(() {
      prodiList = res;
    });
  }

  Future<void> fetchMatkul() async {
    setState(() => loading = true);

    // ambil semua matkul + semua prodi yang berelasi (many-to-many via matkul_prodi)
    final res = await supabase
        .from('matkul')
        .select('''
          id,
          kode_mk,
          nama_mk,
          sks,
          semester,
          matkul_prodi (
            prodi (
              id,
              nama
            )
          )
        ''')
        .order('kode_mk');

    setState(() {
      matkulList = res;
      loading = false;
    });
  }

  Future<void> searchMatkul(String keyword) async {
    if (keyword.trim().isEmpty) {
      fetchMatkul();
      return;
    }

    final res = await supabase
        .from('matkul')
        .select('''
          id,
          kode_mk,
          nama_mk,
          sks,
          semester,
          matkul_prodi (
            prodi (
              id,
              nama
            )
          )
        ''')
        .or('kode_mk.ilike.%$keyword%,nama_mk.ilike.%$keyword%');

    setState(() {
      matkulList = res;
    });
  }

  Future<void> deleteMatkul(int id) async {
    await supabase.from('matkul').delete().eq('id', id);
    fetchMatkul();
  }

  // ----- DIALOG TAMBAH / EDIT (many-to-many) -----
  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final kodeC = TextEditingController(text: existing?['kode_mk'] ?? '');
    final namaC = TextEditingController(text: existing?['nama_mk'] ?? '');
    final sksC = TextEditingController(
      text: existing?['sks']?.toString() ?? '',
    );
    final semesterC = TextEditingController(
      text: existing?['semester']?.toString() ?? '',
    );

    // list id prodi yang terpilih
    List<int> selectedProdiIds = [];

    if (existing != null && existing['matkul_prodi'] != null) {
      final rel = existing['matkul_prodi'] as List<dynamic>;
      selectedProdiIds = rel
          .map<int>((e) => (e['prodi']?['id'] as int))
          .toList();
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            // fungsi untuk buka bottom sheet pilih prodi
            Future<void> openProdiPicker() async {
              // copy sementara
              List<int> tempSelected = List<int>.from(selectedProdiIds);

              final result = await showModalBottomSheet<List<int>>(
                context: dialogContext,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (sheetCtx) {
                  return StatefulBuilder(
                    builder: (sheetCtx, setStateSheet) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const Text(
                                'Pilih Prodi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (prodiList.isEmpty)
                                const Text('Belum ada data prodi')
                              else
                                Flexible(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: prodiList.length,
                                    itemBuilder: (context, index) {
                                      final p =
                                          prodiList[index]
                                              as Map<String, dynamic>;
                                      final pid = p['id'] as int;
                                      final namaProdi = p['nama'] as String;
                                      final isSelected = tempSelected.contains(
                                        pid,
                                      );

                                      return CheckboxListTile(
                                        title: Text(namaProdi),
                                        value: isSelected,
                                        onChanged: (v) {
                                          setStateSheet(() {
                                            if (v == true) {
                                              tempSelected.add(pid);
                                            } else {
                                              tempSelected.remove(pid);
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(sheetCtx, null),
                                    child: const Text('Batal'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(sheetCtx, tempSelected),
                                    child: const Text('Simpan'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );

              if (result != null) {
                setStateDialog(() {
                  selectedProdiIds = result;
                });
              }
            }

            // helper nama prodi terpilih
            List<String> selectedProdiNames() {
              final names = <String>[];
              for (final pid in selectedProdiIds) {
                final match = prodiList.cast<Map<String, dynamic>>().where(
                  (p) => p['id'] == pid,
                );
                if (match.isNotEmpty) {
                  names.add(match.first['nama'] as String);
                }
              }
              return names;
            }

            return AlertDialog(
              title: Text(existing == null ? 'Tambah Matkul' : 'Edit Matkul'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: kodeC,
                      decoration: const InputDecoration(labelText: 'Kode MK'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: namaC,
                      decoration: const InputDecoration(labelText: 'Nama MK'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: sksC,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'SKS'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: semesterC,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Semester'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Prodi terkait',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),

                    // Tombol / field klik "Pilih..."
                    InkWell(
                      onTap: openProdiPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedProdiIds.isEmpty
                                  ? 'Pilih...'
                                  : '${selectedProdiIds.length} prodi dipilih',
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),

                    // Chips nama prodi yang sudah dipilih
                    if (selectedProdiIds.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: selectedProdiNames().map((namaProdi) {
                          final pid =
                              prodiList.cast<Map<String, dynamic>>().firstWhere(
                                    (p) => p['nama'] == namaProdi,
                                  )['id']
                                  as int;
                          return Chip(
                            label: Text(namaProdi),
                            onDeleted: () {
                              setStateDialog(() {
                                selectedProdiIds.remove(pid);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final kode = kodeC.text.trim();
                    final nama = namaC.text.trim();
                    final sks = int.tryParse(sksC.text.trim());
                    final semester = int.tryParse(semesterC.text.trim());

                    if (kode.isEmpty || nama.isEmpty) return;

                    // Kalau tabel matkul kamu masih punya kolom prodi_id
                    // isi saja dengan prodi pertama (atau null kalau tidak dipilih)
                    final int? firstProdiId = selectedProdiIds.isNotEmpty
                        ? selectedProdiIds.first
                        : null;

                    final payload = <String, dynamic>{
                      'kode_mk': kode,
                      'nama_mk': nama,
                      'sks': sks,
                      'semester': semester,
                      'prodi_id': firstProdiId, // opsional, tergantung skema DB
                    };

                    if (existing == null) {
                      // INSERT MATAKULIAH
                      final inserted = await supabase
                          .from('matkul')
                          .insert(payload)
                          .select()
                          .single();

                      final mid = inserted['id'] as int;

                      // INSERT RELASI KE TABEL PIVOT matkul_prodi
                      if (selectedProdiIds.isNotEmpty) {
                        final rows = selectedProdiIds
                            .map((pid) => {'matkul_id': mid, 'prodi_id': pid})
                            .toList();
                        await supabase.from('matkul_prodi').insert(rows);
                      }
                    } else {
                      final mid = existing['id'] as int;

                      // UPDATE DATA MATKUL
                      await supabase
                          .from('matkul')
                          .update(payload)
                          .eq('id', mid);

                      // HAPUS RELASI LAMA DI TABEL PIVOT
                      await supabase
                          .from('matkul_prodi')
                          .delete()
                          .eq('matkul_id', mid);

                      // INSERT RELASI BARU
                      if (selectedProdiIds.isNotEmpty) {
                        final rows = selectedProdiIds
                            .map((pid) => {'matkul_id': mid, 'prodi_id': pid})
                            .toList();
                        await supabase.from('matkul_prodi').insert(rows);
                      }
                    }

                    if (context.mounted) Navigator.pop(dialogContext);
                    fetchMatkul();
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Mata Kuliah'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchMatkul),
          IconButton(icon: const Icon(Icons.add), onPressed: () => _openForm()),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchC,
              decoration: InputDecoration(
                hintText: 'Cari kode atau nama matkul...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: searchMatkul,
            ),
          ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : matkulList.isEmpty
                ? const Center(child: Text('Belum ada data matkul'))
                : ListView.builder(
                    itemCount: matkulList.length,
                    itemBuilder: (context, index) {
                      final m = matkulList[index] as Map<String, dynamic>;
                      final kode = m['kode_mk'] ?? '';
                      final nama = m['nama_mk'] ?? '';
                      final sks = m['sks'];
                      final semester = m['semester'];

                      // Ambil semua nama prodi dari relasi matkul_prodi
                      String prodiNamaStr = '-';
                      if (m['matkul_prodi'] != null &&
                          (m['matkul_prodi'] as List).isNotEmpty) {
                        final rel = m['matkul_prodi'] as List<dynamic>;
                        final namaList = rel
                            .map((e) => e['prodi']?['nama'] as String?)
                            .where((e) => e != null && e.isNotEmpty)
                            .cast<String>()
                            .toList();
                        if (namaList.isNotEmpty) {
                          prodiNamaStr = namaList.join(', ');
                        }
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text('$kode • $nama'),
                          subtitle: Text(
                            'SKS: ${sks ?? '-'} | Semester: ${semester ?? '-'}\nProdi: $prodiNamaStr',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _openForm(existing: m),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => deleteMatkul(m['id'] as int),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
