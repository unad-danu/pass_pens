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

  Future<void> markAsRead(int id) async {
    try {
      await supabase.rpc('read_notification', params: {"notif_id": id});
    } catch (e) {
      debugPrint("Error marking read: $e");
    }
  }

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

                        // cari jadwal detail berdasarkan jadwalId
                        final jadwal = await supabase
                            .from("jadwal")
                            .select("""
      id,
      jam_mulai,
      jam_selesai,
      matkul:matkul_id (nama_mk),
      dosen:dosen_id (nama),
      ruangan:ruangan_id (nama)
    """)
                            .eq("id", jadwalId)
                            .single();

                        if (!mounted) return;

                        if (role == "mhs") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailMatkulMahasiswaPage(
                                jadwalId: jadwalId,
                                namaMatkul: jadwal["matkul"]["nama_mk"] ?? "",
                                dosen: jadwal["dosen"]["nama"] ?? "",
                                ruangan: jadwal["ruangan"]["nama"] ?? "",
                                jadwal:
                                    "${jadwal["jam_mulai"]} - ${jadwal["jam_selesai"]}",
                                attendanceTerakhir: "",
                                latitude: 0, // jadwal tidak punya latitude
                                longitude: 0,
                                isOffline: false,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailMatkulDosenPage(
                                jadwalId: jadwalId,
                                namaMatkul: jadwal["matkul"] ?? "",
                                jamMulai: jadwal["jam_mulai"] ?? "",
                                jamSelesai: jadwal["jam_selesai"] ?? "",
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
