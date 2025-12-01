import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminKelolaRuanganPage extends StatefulWidget {
  const AdminKelolaRuanganPage({super.key});

  @override
  State<AdminKelolaRuanganPage> createState() => _AdminKelolaRuanganPageState();
}

class _AdminKelolaRuanganPageState extends State<AdminKelolaRuanganPage> {
  final supabase = Supabase.instance.client;

  List<dynamic> ruanganList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadRuangan();
  }

  Future<void> loadRuangan() async {
    setState(() => loading = true);

    final data = await supabase.from('ruangan').select().order('id');

    setState(() {
      ruanganList = data;
      loading = false;
    });
  }

  // =============== FORM TAMBAH / EDIT ===============
  Future<void> openRuanganForm({Map<String, dynamic>? existing}) async {
    final txtKode = TextEditingController(text: existing?['kode'] ?? '');
    final txtNama = TextEditingController(text: existing?['nama'] ?? '');
    final txtKapasitas = TextEditingController(
      text: existing?['kapasitas']?.toString() ?? '',
    );
    final txtLokasi = TextEditingController(text: existing?['lokasi'] ?? '');

    final isEdit = existing != null;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(isEdit ? "Edit Ruangan" : "Tambah Ruangan"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: txtKode,
                  decoration: const InputDecoration(labelText: "Kode Ruangan"),
                ),
                TextField(
                  controller: txtNama,
                  decoration: const InputDecoration(labelText: "Nama Ruangan"),
                ),
                TextField(
                  controller: txtKapasitas,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Kapasitas"),
                ),
                TextField(
                  controller: txtLokasi,
                  decoration: const InputDecoration(
                    labelText: "Lokasi / Gedung",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final kode = txtKode.text.trim();
                final nama = txtNama.text.trim();
                final kapasitas = int.tryParse(txtKapasitas.text.trim()) ?? 0;
                final lokasi = txtLokasi.text.trim();

                if (kode.isEmpty || nama.isEmpty) return;

                if (isEdit) {
                  await supabase
                      .from('ruangan')
                      .update({
                        'kode': kode,
                        'nama': nama,
                        'kapasitas': kapasitas,
                        'lokasi': lokasi,
                      })
                      .eq('id', existing['id']);
                } else {
                  await supabase.from('ruangan').insert({
                    'kode': kode,
                    'nama': nama,
                    'kapasitas': kapasitas,
                    'lokasi': lokasi,
                  });
                }

                Navigator.pop(context);
                await loadRuangan();
              },
              child: Text(isEdit ? "Simpan" : "Tambah"),
            ),
          ],
        );
      },
    );
  }

  // =============== HAPUS ===============
  Future<void> deleteRuangan(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Ruangan"),
        content: const Text("Yakin ingin menghapus ruangan ini?"),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Hapus"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.from('ruangan').delete().eq('id', id);
      loadRuangan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Ruangan"),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadRuangan),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => openRuanganForm(),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: ruanganList.length,
              itemBuilder: (context, index) {
                final r = ruanganList[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text("${r['kode']} - ${r['nama']}"),
                    subtitle: Text(
                      "Kapasitas: ${r['kapasitas']} | Lokasi: ${r['lokasi'] ?? '-'}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => openRuanganForm(existing: r),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteRuangan(r['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
