import Comment from "../models/Comments.js";
import Post from "../models/Post.js";

// commentController.js
export const addComment = async (req, res) => {
    const { postId, comment, status } = req.body;

    // Cek apakah data yang dibutuhkan ada
    if (!postId || !comment || status === undefined) {
        return res.status(400).json({ message: "postId, comment, and status are required." });
    }

    try {
        const newComment = new Comment({
            postId,
            comment,
            status,
            postBy: req.user.id, // Menyimpan ID pengguna yang membuat komentar
        });

        const post = await Post.findById(postId);
        post.commentCount = post.commentCount + 1; // Increment the comment count
        await post.save();

        const savedComment = await newComment.save();
        res.status(201).json(savedComment); // Mengembalikan komentar yang disimpan
    } catch (error) {
        res.status(500).json({ message: error.message }); // Menangani kesalahan
    }
};


export const getComments = async (req, res) => {
    const { postId } = req.params;
    const { parentCommentId } = req.query;

    try {
        const filter = parentCommentId
            ? { parentCommentId, postId, status: 1 }
            : { postId, status: 0 };

        const comments = await Comment.find(filter)
            .populate("postBy", "nickname profilePict") // Mengambil data user
            .populate("postId", "textContent"); // Mengambil data post yang terkait

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

        // Decrement reply count untuk parent comment atau post
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
