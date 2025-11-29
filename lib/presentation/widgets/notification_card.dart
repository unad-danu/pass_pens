import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool highlight;
  final String? imageUrl;

  final VoidCallback? onTap; // <— tambahan

  const NotificationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    this.highlight = false,
    this.imageUrl,
    this.onTap, // <— tambahan
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // <— aktifkan onTap
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFFE2EEF8) : Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar kiri (opsional)
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),

            if (imageUrl != null) const SizedBox(width: 10),

            // Bagian teks (tetap sama)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE + TIME
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // SUBTITLE
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
