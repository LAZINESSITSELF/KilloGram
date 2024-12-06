class User {
  final String nickname;
  final String profilePicture;

  User({
    required this.nickname,
    required this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      nickname: json['nickname'] ?? 'Anonymous',
      profilePicture: json['profilePict'] ?? '',
    );
  }
}

class Comment {
  final String commentId;
  final String? comment;
  final String createdOn;
  final User postBy;

  Comment({
    required this.commentId,
    this.comment,
    required this.createdOn,
    required this.postBy,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['_id'],
      comment: json['comment'],
      createdOn: json['createdOn'],
      postBy: User.fromJson(json['postBy']),
    );
  }
}
