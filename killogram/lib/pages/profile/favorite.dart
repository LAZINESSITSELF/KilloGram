import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:killogram/models/post.dart';
import 'package:timeago/timeago.dart' as timeago;

class FavoritePage extends StatefulWidget {
  final List<Post> favoritePosts;
  final Function(Post) toggleFavorite;

  const FavoritePage({
    Key? key,
    required this.favoritePosts,
    required this.toggleFavorite,
  }) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorites')),
      body: widget.favoritePosts.isEmpty
          ? Center(
              child: Text(
                'No favorite posts yet!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: widget.favoritePosts.length,
              itemBuilder: (context, index) {
                final post = widget.favoritePosts[index];
                final postDate = DateTime.parse(post.createdOn);
                final relativeTime = timeago.format(postDate);
                final formattedDate =
                    DateFormat('d MMMM y, HH:mm').format(postDate);

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
                          Spacer(), // Menggeser tombol save ke kanan
                          IconButton(
                            icon: Icon(
                              Icons.bookmark_remove,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              widget.toggleFavorite(post);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
