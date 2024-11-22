class Like {
  final int id;
  final String postId; // Gunakan postId sebagai String
  final String userId; // Gunakan userId sebagai String

  Like({
    required this.id,
    required this.postId,
    required this.userId,
  });

  // Factory untuk mengonversi JSON ke objek Like
  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['_id'],
      postId: json['postId'],
      userId: json['userId'],
    );
  }

  // Method untuk mengonversi objek Like ke JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'postId': postId,
      'userId': userId,
    };
  }
}