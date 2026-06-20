class ArticleModel {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String newsSite;
  final String publishedAt;
  final String url;

  ArticleModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.newsSite,
    required this.publishedAt,
    required this.url,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Tanpa Judul',
      summary: json['summary']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      newsSite: json['news_site']?.toString() ?? '-',
      publishedAt: json['published_at']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }

  // Dipakai saat membaca data dari koleksi "favorites" di Firestore
  factory ArticleModel.fromFavoriteMap(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['articleId']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Tanpa Judul',
      summary: map['summary']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      newsSite: map['newsSite']?.toString() ?? '-',
      publishedAt: map['publishedAt']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
    );
  }
}
