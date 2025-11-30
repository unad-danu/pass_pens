import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminKelolaDosenPage extends StatefulWidget {
  const AdminKelolaDosenPage({super.key});

  @override
  State<AdminKelolaDosenPage> createState() => _AdminKelolaDosenPageState();
}

class _AdminKelolaDosenPageState extends State<AdminKelolaDosenPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> dosenList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchDosen();
  }

  Future<void> fetchDosen() async {
    try {
      final response = await supabase.from('dosen').select();
      setState(() {
        dosenList = response;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint('Error: $e');
    }
  }

  Future<void> deleteDosen(String id) async {
    try {
      await supabase.from('dosen').delete().eq('id', id);
      fetchDosen();
    } catch (e) {
      debugPrint('Delete Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Dosen'),
        backgroundColor: Colors.blueAccent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: dosenList.length,
              itemBuilder: (context, index) {
                final dosen = dosenList[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(dosen['nama'] ?? 'Tanpa Nama'),
                    subtitle: Text(dosen['email'] ?? '-'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteDosen(dosen['id'].toString()),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
