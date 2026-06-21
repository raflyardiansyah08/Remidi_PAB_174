import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/prefs_service.dart';
import '../../utils/app_colors.dart';
import '../auth/register_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 1. Hapus status session login lokal
    await PrefsService().clearSession();
    // 2. Sign out dari Firebase
    await AuthService().logout();

    if (!context.mounted) return;

    // 3. Bersihkan seluruh tumpukan halaman -> kembali ke Halaman Daftar
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final firestoreService = FirestoreService();

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: uid.isEmpty
                ? const Center(child: Text('Silakan login terlebih dahulu.'))
                : StreamBuilder(
                    stream: firestoreService.userStream(uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      UserModel user;
                      if (snapshot.hasData && snapshot.data!.exists) {
                        user = UserModel.fromMap(uid, snapshot.data!.data()!);
                      } else {
                        user = UserModel(
                          uid: uid,
                          name: '-',
                          email: FirebaseAuth.instance.currentUser?.email ?? '-',
                          instagram: '-',
                          photoUrl: '',
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              backgroundImage: user.photoUrl.isNotEmpty
                                  ? NetworkImage(user.photoUrl)
                                  : null,
                              child: user.photoUrl.isEmpty
                                  ? const Icon(Icons.person,
                                      size: 55, color: AppColors.primary)
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              user.name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(user.email,
                                style:
                                    const TextStyle(color: AppColors.textGrey)),
                            const SizedBox(height: 24),
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _profileRow(Icons.email_outlined, 'Email',
                                        user.email),
                                    const Divider(),
                                    _instagramRow(
                                        context, uid, user.instagram, firestoreService),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () => _handleLogout(context),
                              icon: const Icon(Icons.logout),
                              label: const Text('Log Out'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Flexible(
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Baris Instagram yang bisa diedit oleh user (input username Instagram)
  Widget _instagramRow(
    BuildContext context,
    String uid,
    String instagram,
    FirestoreService firestoreService,
  ) {
    final displayValue =
        (instagram.isEmpty || instagram == '-') ? 'Belum diisi' : instagram;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.camera_alt_outlined,
              size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          const Text('Instagram',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Flexible(
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18, color: AppColors.textGrey),
            tooltip: 'Edit Instagram',
            onPressed: () => _showEditInstagramDialog(
              context,
              uid,
              instagram,
              firestoreService,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog input untuk mengisi/mengubah username Instagram
  Future<void> _showEditInstagramDialog(
    BuildContext context,
    String uid,
    String currentValue,
    FirestoreService firestoreService,
  ) async {
    final controller = TextEditingController(
      text: (currentValue == '-') ? '' : currentValue,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Username Instagram'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.alternate_email),
            hintText: 'username_instagram',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == null) return;
    if (!context.mounted) return;

    try {
      await firestoreService.updateInstagram(uid, result);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Instagram berhasil diperbarui')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui Instagram'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
