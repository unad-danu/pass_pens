import 'package:flutter/material.dart';

class AdminKelolaKelasPage extends StatelessWidget {
  const AdminKelolaKelasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Kelas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (ctx, i) {
          return Card(
            child: ListTile(
              title: Text('Kelas ${String.fromCharCode(65 + i)}'),
              subtitle: const Text('Jumlah Mahasiswa: 30'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.edit, color: Colors.orange),
                  SizedBox(width: 10),
                  Icon(Icons.delete, color: Colors.red),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
