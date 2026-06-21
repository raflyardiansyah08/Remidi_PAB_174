import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class _NotificationItem {
  final String title;
  final String subtitle;
  final DateTime time;
  final IconData icon;

  _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });
}

class NotificationTab extends StatelessWidget {
  const NotificationTab({super.key});

  List<_NotificationItem> _buildMockNotifications() {
    final now = DateTime.now();
    final items = [
      _NotificationItem(
        title: 'Breaking News',
        subtitle: 'Ada artikel baru di kategori Space Exploration.',
        time: now.subtract(const Duration(minutes: 10)),
        icon: Icons.bolt,
      ),
      _NotificationItem(
        title: 'Update Favorit',
        subtitle: 'Artikel yang Anda simpan telah diperbarui.',
        time: now.subtract(const Duration(hours: 2)),
        icon: Icons.favorite,
      ),
      _NotificationItem(
        title: 'Selamat Datang!',
        subtitle: 'Terima kasih telah menggunakan SpaceNews Core.',
        time: now.subtract(const Duration(hours: 6)),
        icon: Icons.celebration,
      ),
      _NotificationItem(
        title: 'Rangkuman Harian',
        subtitle: '20 berita baru tersedia untuk Anda baca hari ini.',
        time: now.subtract(const Duration(days: 1)),
        icon: Icons.summarize,
      ),
    ];
    // Urutkan dari yang terbaru
    items.sort((a, b) => b.time.compareTo(a.time));
    return items;
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    return '${diff.inDays} hari yang lalu';
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _buildMockNotifications();

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notification',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(item.icon, color: AppColors.primary),
                  ),
                  title: Text(item.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(item.subtitle),
                  trailing: Text(
                    _timeAgo(item.time),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textGrey),
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
