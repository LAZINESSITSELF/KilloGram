import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:killogram/models/comment.dart';
import 'package:killogram/services/commentController.dart';

class CommentModal extends StatefulWidget {
  final String postId;

  const CommentModal({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends State<CommentModal> {
  late Future<List<Comment>> futureComments;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureComments = CommentService().fetchComments(widget.postId);
  }

  Future<void> _addComment() async {
    if (commentController.text.isNotEmpty) {
      try {
        await CommentService()
            .addComment(widget.postId, commentController.text);
        setState(() {
          futureComments =
              CommentService().fetchComments(widget.postId); // Refresh comments
        });
        commentController.clear();
      } catch (e) {
        // Handle any errors that may occur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7, // Adjust initial size of the modal
      minChildSize: 0.3, // Minimum size when fully collapsed
      maxChildSize: 1.0, // Maximum size of the modal
      builder: (context, controller) {
        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comments',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Comment>>(
                  future: futureComments,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No comments yet.'));
                    } else {
                      final comments = snapshot.data!;
                      return ListView.builder(
                        controller: controller,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final commentDate = DateTime.parse(comment.createdOn);
                          final relativeTime = timeago.format(commentDate);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: comment
                                      .postBy.profilePicture.isNotEmpty
                                  ? NetworkImage(comment.postBy.profilePicture)
                                  : AssetImage(
                                          'assets/images/default/default-profile.png')
                                      as ImageProvider,
                            ),
                            title: Text(comment.postBy.nickname),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (comment.comment != null)
                                  Text(comment.comment!),
                                Text(
                                  relativeTime,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _addComment,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
