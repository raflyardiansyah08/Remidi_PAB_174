class UserModel {
  final String uid;
  final String name;
  final String email;
  final String instagram;
  final String photoUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.instagram,
    required this.photoUrl,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name']?.toString() ?? '-',
      email: map['email']?.toString() ?? '-',
      instagram: map['instagram']?.toString() ?? '-',
      photoUrl: map['photoUrl']?.toString() ?? '',
    );
  }
}
