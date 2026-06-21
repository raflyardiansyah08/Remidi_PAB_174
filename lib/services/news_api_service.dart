import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class NewsApiService {
  static const String _baseUrl =
      'https://api.spaceflightnewsapi.net/v4/articles/?limit=20';

  Future<List<ArticleModel>> fetchArticles() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List results = data['results'] ?? [];
      return results
          .map((item) => ArticleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat berita (status ${response.statusCode})');
    }
  }
}
