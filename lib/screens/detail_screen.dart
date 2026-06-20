import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class DetailScreen extends StatefulWidget {
  final ArticleModel article;

  const DetailScreen({super.key, required this.article});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  String _formatDate(String iso) {
    try {
      final date = DateTime.parse(iso);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '-';
    }
  }

  Future<void> _toggleFavorite(bool isCurrentlyFavorite) async {
    if (_uid.isEmpty) return;
    if (isCurrentlyFavorite) {
      await _firestoreService.removeFavorite(_uid, widget.article.id);
    } else {
      await _firestoreService.addFavorite(_uid, widget.article);
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: AppColors.primary,
            // Tombol Back disediakan otomatis oleh Navigator/AppBar
            actions: [
              StreamBuilder<dynamic>(
                stream: _uid.isEmpty
                    ? null
                    : _firestoreService.favoriteStatusStream(_uid, article.id),
                builder: (context, snapshot) {
                  final isFavorite =
                      snapshot.hasData && snapshot.data!.exists == true;
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.favoriteRed : Colors.white,
                    ),
                    onPressed: () => _toggleFavorite(isFavorite),
                  );
                },
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              CachedNetworkImage(
                imageUrl: article.imageUrl,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 240,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 240,
                  color: AppColors.primary,
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.white, size: 60),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.rss_feed,
                            size: 16, color: AppColors.textGrey),
                        const SizedBox(width: 6),
                        Text(
                          article.newsSite,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.calendar_today,
                            size: 14, color: AppColors.textGrey),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(article.publishedAt),
                          style: const TextStyle(
                              color: AppColors.textGrey, fontSize: 13),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    Text(
                      article.summary.isEmpty
                          ? 'Tidak ada ringkasan untuk artikel ini.'
                          : article.summary,
                      style: const TextStyle(fontSize: 15.5, height: 1.6),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
