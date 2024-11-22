import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:killogram/models/post.dart';
import 'package:killogram/services/postController.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Post>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = PostService().fetchPosts(); // Ambil data postingan saat halaman dimuat
  }

  // Fungsi untuk memeriksa status like
  Future<void> checkIfLiked(Post post) async {
    bool isLiked = await PostService().checkIfPostLiked(post.postid);
    setState(() {
      post.isLiked = isLiked;
    });
  }

  // Fungsi untuk menyegarkan data postingan
  Future<void> refreshData() async {
    setState(() {
      futurePosts = PostService().fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('KilloGram')),
      body: FutureBuilder<List<Post>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No posts available'));
          } else {
            final posts = snapshot.data!
              ..sort((a, b) => b.createdOn.compareTo(a.createdOn));

            return RefreshIndicator(
              onRefresh: refreshData, // Memicu refresh data saat di geser ke bawah
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final postDate = DateTime.parse(post.createdOn);
                  final relativeTime = timeago.format(postDate);
                  final formattedDate =
                      DateFormat('d MMMM y, HH:mm').format(postDate);

                  // Memeriksa apakah post telah disukai pengguna
                  checkIfLiked(post);

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(post.postBy.nickname),
                          subtitle: Text(relativeTime),
                          leading: CircleAvatar(
                            backgroundImage: post.postBy.profilePicture.isNotEmpty
                                ? NetworkImage(post.postBy.profilePicture)
                                : null,
                            child: post.postBy.profilePicture.isEmpty
                                ? Text(post.postBy.nickname[0])
                                : null,
                          ),
                        ),
                        if (post.textContent != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(post.textContent!),
                          ),
                        if (post.urlMedia != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                post.urlMedia!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              (loadingProgress
                                                      .expectedTotalBytes ??
                                                  1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    height: 200,
                                    width: double.infinity,
                                    child: Icon(Icons.broken_image,
                                        color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            formattedDate,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                post.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: post.isLiked ? Colors.red : null,
                              ),
                              onPressed: () async {
                                try {
                                  if (post.isLiked) {
                                    await PostService().unlikePost(post.postid);
                                    setState(() {
                                      post.isLiked = false;
                                      post.likeCount--;
                                    });
                                  } else {
                                    await PostService().likePost(post.postid);
                                    setState(() {
                                      post.isLiked = true;
                                      post.likeCount++;
                                    });
                                  }
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error liking post')),
                                  );
                                }
                              },
                            ),
                            Text('${post.likeCount}'),
                            SizedBox(width: 20),
                            IconButton(
                                icon: Icon(Icons.comment), onPressed: () {}),
                            Text('${post.commentCount} Comments'),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
