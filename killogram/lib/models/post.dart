class User {
  final String nickname;
  final String profilePicture;

  User({
    required this.nickname,
    required this.profilePicture,
  });

  // Factory untuk membuat instance User dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      nickname: json['nickname'] ?? 'Anonymous',
      profilePicture: json['profilePict'] ?? '',
    );
  }
}

class Post {
  final String postid;
  final String? urlMedia;
  final String? textContent;
  int likeCount;
  final int commentCount;
  final User postBy;
  final String createdOn;
  bool isLiked; // Tambahkan status ini

  Post({
    required this.postid,
    this.urlMedia,
    this.textContent,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.postBy,
    required this.createdOn,
    this.isLiked = false, // Default ke false
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postid: json['_id'],
      urlMedia: json['urlMedia'],
      textContent: json['textContent'],
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
      postBy: User.fromJson(json['postBy']),
      createdOn: json['createdOn'],
      isLiked: json['isLiked'] ?? false, // Tambahkan jika API mendukung
    );
  }
}
