import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../widgets/custom_appbar.dart';
import '../widgets/notification_card.dart';
import '../pages/detail_matkul_mahasiswa_page.dart';
import '../pages/detail_matkul_dosen_page.dart';

class NotificationPage extends StatefulWidget {
  final String? role;

  const NotificationPage({super.key, this.role});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> futureNotif;

  @override
  void initState() {
    super.initState();
    futureNotif = loadNotifications();
  }

  // 🔥 Ambil notifikasi
  Future<List<Map<String, dynamic>>> loadNotifications() async {
    try {
      final response = await supabase
          .from('notifications')
          .select('id, jadwal_id, title, subtitle, highlight, created_at')
          .eq('role', widget.role ?? "")
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error loading notifications: $e");
      return [];
    }
  }

  // 🔥 Tandai sebagai dibaca
  Future<void> markAsRead(int id) async {
    try {
      await supabase.rpc('read_notification', params: {"notif_id": id});
    } catch (e) {
      debugPrint("Error marking read: $e");
    }
  }

  // 🔥 Convert ke timeago
  String timeAgo(String? timestamp) {
    if (timestamp == null) return "";
    try {
      return timeago.format(DateTime.parse(timestamp).toLocal(), locale: "en");
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(role: role),

      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            "Notifications",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureNotif,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Tidak ada notifikasi"));
                }

                final list = snapshot.data!;

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final n = list[index];

                    final int jadwalId = (n["jadwal_id"] ?? 0) as int;
                    final int notifId = (n["id"] ?? 0) as int;

                    return NotificationCard(
                      title: n["title"] ?? "",
                      subtitle: n["subtitle"] ?? "",
                      time: timeAgo(n["created_at"]),
                      highlight: n["highlight"] ?? true,

                      onTap: () async {
                        await markAsRead(notifId);

                        if (!mounted) return;

                        // refresh list
                        setState(() => futureNotif = loadNotifications());

                        // Route
                        if (role == "mhs") {
                          if (!mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailMatkulMahasiswaPage(
                                namaMatkul: n["title"] ?? "",
                                jadwalId: jadwalId,
                                dosen: "",
                                ruangan: "",
                                jadwal: "",
                                attendanceTerakhir: "",
                                latitude: 0,
                                longitude: 0,
                                isOffline: false,
                              ),
                            ),
                          );
                        } else {
                          if (!mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailMatkulDosenPage(
                                nama: n["title"] ?? "",
                                ruangan: "",
                                jam: "",
                                jadwalId: jadwalId,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
