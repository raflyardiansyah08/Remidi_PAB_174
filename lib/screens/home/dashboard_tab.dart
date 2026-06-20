import 'package:flutter/material.dart';
import '../../models/article_model.dart';
import '../../services/news_api_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/headline_banner.dart';
import '../../widgets/news_card.dart';
import '../detail_screen.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final NewsApiService _newsApiService = NewsApiService();
  late Future<List<ArticleModel>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = _newsApiService.fetchArticles();
  }

  Future<void> _refresh() async {
    setState(() {
      _articlesFuture = _newsApiService.fetchArticles();
    });
    await _articlesFuture;
  }

  void _openDetail(ArticleModel article) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(article: article)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'SpaceNews Core',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ArticleModel>>(
              future: _articlesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text('Gagal memuat berita: ${snapshot.error}',
                              textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _refresh,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final articles = snapshot.data ?? [];
                if (articles.isEmpty) {
                  return const Center(child: Text('Tidak ada berita.'));
                }

                final headline = articles.first;
                final rest = articles.skip(1).toList();

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    children: [
                      HeadlineBanner(
                        article: headline,
                        onTap: () => _openDetail(headline),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(
                          'Berita Lainnya',
                          style:
                              TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...rest.map(
                        (article) => NewsCard(
                          article: article,
                          onTap: () => _openDetail(article),
                        ),
                      ),
                      const SizedBox(height: 16),
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
}
