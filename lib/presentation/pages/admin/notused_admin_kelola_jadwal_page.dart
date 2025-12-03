import 'package:flutter/material.dart';

class AdminKelolaJadwalPage extends StatelessWidget {
  const AdminKelolaJadwalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Jadwal')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (ctx, i) {
          return Card(
            child: ListTile(
              title: Text('Jadwal ${i + 1}'),
              subtitle: const Text('Senin • 07.00 - 09.00'),
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
