import Comment from "../models/Comments.js";
import Post from "../models/Post.js";

export const addComment = async (req, res) => {
  const { comment, contentURL, postBy, postId, parentCommentId, status } = req.body;

  if (!postBy || !postId || status === undefined) {
    return res.status(400).json({ message: "postBy, postId, and status are required." });
  }

  try {
    const newComment = new Comment({
      comment,
      contentURL,
      postBy,
      postId,
      status,
      parentCommentId: parentCommentId || null,
    });

    const savedComment = await newComment.save();

    // Increment reply count for parent comment or post
    if (status === 1 && parentCommentId) {
      await Comment.findByIdAndUpdate(parentCommentId, {
        $inc: { replyCount: 1 },
      });
    } else if (status === 0) {
      await Post.findByIdAndUpdate(postId, {
        $inc: { replyCount: 1 },
      });
    }

    res.status(201).json(savedComment);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getComments = async (req, res) => {
  const { postId } = req.params;
  const { parentCommentId } = req.query;

  try {
    const filter = parentCommentId
      ? { parentCommentId, postId, status: 1 }
      : { postId, status: 0 };
    const comments = await Comment.find(filter).populate("postBy", "username");
    res.status(200).json(comments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const updateComment = async (req, res) => {
  const { commentId } = req.params;
  const { comment, contentURL, status } = req.body;

  try {
    const updatedComment = await Comment.findByIdAndUpdate(
      commentId,
      { comment, contentURL, status, updatedOn: Date.now() },
      { new: true }
    );

    if (!updatedComment) {
      return res.status(404).json({ message: "Comment not found." });
    }

    res.status(200).json(updatedComment);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const deleteComment = async (req, res) => {
  const { commentId } = req.params;

  try {
    const deletedComment = await Comment.findByIdAndDelete(commentId);

    if (!deletedComment) {
      return res.status(404).json({ message: "Comment not found." });
    }

    // Decrement reply count for parent comment or post
    if (deletedComment.status === 1 && deletedComment.parentCommentId) {
      await Comment.findByIdAndUpdate(deletedComment.parentCommentId, {
        $inc: { replyCount: -1 },
      });
    } else if (deletedComment.status === 0) {
      await Post.findByIdAndUpdate(deletedComment.postId, {
        $inc: { replyCount: -1 },
      });
    }

    res.status(200).json({ message: "Comment deleted successfully." });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};