import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/article_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ----------------- USERS -----------------

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }

  /// Menyimpan/memperbarui username Instagram milik user
  Future<void> updateInstagram(String uid, String instagram) {
    return _firestore.collection('users').doc(uid).set(
      {'instagram': instagram},
      SetOptions(merge: true),
    );
  }

  // ----------------- FAVORITES -----------------
  // Doc id dibuat deterministik: "<uid>_<articleId>"
  // sehingga mudah dicek statusnya secara realtime per artikel.

  String _favDocId(String uid, String articleId) => '${uid}_$articleId';

  Stream<DocumentSnapshot<Map<String, dynamic>>> favoriteStatusStream(
    String uid,
    String articleId,
  ) {
    return _firestore
        .collection('favorites')
        .doc(_favDocId(uid, articleId))
        .snapshots();
  }

  Future<void> addFavorite(String uid, ArticleModel article) {
    return _firestore.collection('favorites').doc(_favDocId(uid, article.id)).set({
      'userId': uid,
      'articleId': article.id,
      'title': article.title,
      'summary': article.summary,
      'imageUrl': article.imageUrl,
      'newsSite': article.newsSite,
      'publishedAt': article.publishedAt,
      'url': article.url,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String uid, String articleId) {
    return _firestore.collection('favorites').doc(_favDocId(uid, articleId)).delete();
  }

  /// Stream realtime seluruh favorite milik user yang sedang login.
  /// Catatan: orderBy sengaja tidak dipakai di query agar tidak memerlukan
  /// composite index di Firestore. Urutan terbaru->terlama diatur di sisi
  /// aplikasi (lihat favorite_tab.dart).
  Stream<QuerySnapshot<Map<String, dynamic>>> favoritesStream(String uid) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }
}
