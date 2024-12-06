import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:killogram/models/post.dart';
import 'package:killogram/services/postController.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Post>> futurePosts;
  late WebSocketChannel channel;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    futurePosts = PostService().fetchPosts();
    channel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.4.110:5000')); // Ganti dengan server Anda

    // Inisialisasi notifikasi
    _initializeNotifications();

    // Menerima pesan WebSocket
    channel.stream.listen((message) {
      // Logika untuk menangani notifikasi
      _showNotification('New Like', 'Someone liked your post!');
    });
  }

  // Fungsi untuk menampilkan notifikasi
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails('channel_id', 'channel_name',
            importance: Importance.high, priority: Priority.high);
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: 'notification_payload',
    );
  }

  // Fungsi untuk inisialisasi notifikasi lokal
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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

  // Fungsi untuk menampilkan gambar dalam dialog
  void showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: InteractiveViewer(
            child: Image.network(imageUrl),
          ),
          insetPadding: EdgeInsets.all(0),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    channel.sink.close();
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
              onRefresh: refreshData,
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final postDate = DateTime.parse(post.createdOn);
                  final relativeTime = timeago.format(postDate);
                  final formattedDate =
                      DateFormat('d MMMM y, HH:mm').format(postDate);

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
                            backgroundImage:
                                post.postBy.profilePicture.isNotEmpty
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
                            child: GestureDetector(
                              onTap: () {
                                showImageDialog(context, post.urlMedia!);
                              },
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
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
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
                                    // Mengirim notifikasi setelah like
                                    _showNotification(
                                      'New Like',
                                      'Someone liked your post!',
                                    );
                                  }
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Error liking post')),
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
