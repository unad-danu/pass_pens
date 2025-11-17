import 'package:flutter/material.dart';
import '../utils/supabase_config.dart';

class TestSupabasePage extends StatefulWidget {
  const TestSupabasePage({super.key});

  @override
  State<TestSupabasePage> createState() => _TestSupabasePageState();
}

class _TestSupabasePageState extends State<TestSupabasePage> {
  String log = "";

  void addLog(String text) {
    setState(() {
      log += text + "\n";
    });
  }

  // TEST 1: Query database (cek koneksi)
  Future<void> testDatabase() async {
    try {
      final res = await SupabaseConfig.client
          .from('users')
          .select('id, nama, email')
          .limit(1);

      addLog("DATABASE OK:\n$res");
    } catch (e) {
      addLog("DATABASE ERROR: $e");
    }
  }

  // TEST 2: Cek current session auth (tanpa login)
  Future<void> testAuth() async {
    try {
      final session = SupabaseConfig.client.auth.currentSession;

      if (session == null) {
        addLog("AUTH OK: Tidak ada session (belum login)");
      } else {
        addLog("AUTH OK: Session aktif -> ${session.user.id}");
      }
    } catch (e) {
      addLog("AUTH ERROR: $e");
    }
  }

  // TEST 3: Print URL project (cek inisialisasi)
  Future<void> testConfig() async {
    try {
      final url = SupabaseConfig.client.rest.url;
      addLog("CONFIG OK: URL = $url");
    } catch (e) {
      addLog("CONFIG ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Supabase"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: testDatabase,
              child: const Text("Test Database (Select 1 row)"),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: testAuth,
              child: const Text("Test Auth (currentSession)"),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: testConfig,
              child: const Text("Test Config (URL)"),
            ),
            const SizedBox(height: 20),

            const Text(
              "LOG OUTPUT:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Expanded(child: SingleChildScrollView(child: Text(log))),
          ],
        ),
      ),
    );
  }
}
