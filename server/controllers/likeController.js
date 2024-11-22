import Like from "../models/Like.js";
import Post from "../models/Post.js";

// Menambahkan like ke postingan
export const likePost = async (req, res) => {
  try {
    console.log(req.body);
    const { postId } = req.params;
    const userId = req.user.id; // Diambil dari token pengguna

    // Cek apakah user sudah memberikan like sebelumnya
    const existingLike = await Like.findOne({ postId, userId });
    if (existingLike) {
      return res.status(400).json({ message: "You already liked this post" });
    }

    // Tambahkan like baru
    const newLike = new Like({ postId, userId });
    await newLike.save();

    // Update jumlah like di Post
    await Post.findByIdAndUpdate(postId, { $inc: { likeCount: 1 } });

    res.status(201).json({ message: "Post liked successfully" });
  } catch (error) {
    res.status(500).json({ message: "Error liking post", error });
  }
};

// Menghapus like dari postingan (unlike)
export const unlikePost = async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.id; // Diambil dari token pengguna

    // Cek apakah like ada
    const like = await Like.findOne({ postId, userId });
    if (!like) {
      return res.status(404).json({ message: "Like not found" });
    }

    // Hapus like
    await like.deleteOne();

    // Update jumlah like di Post
    await Post.findByIdAndUpdate(postId, { $inc: { likeCount: -1 } });

    res.status(200).json({ message: "Post unliked successfully" });
  } catch (error) {
    res.status(500).json({ message: "Error unliking post", error });
  }
};

// Mendapatkan semua like pada postingan tertentu
export const getLikes = async (req, res) => {
  try {
    const { postId } = req.params;

    const likes = await Like.find({ postId }).populate("userId", "username profilePict");

    res.status(200).json(likes);
  } catch (error) {
    res.status(500).json({ message: "Error fetching likes", error });
  }
};

export const getLikeStatus = async (req, res) => {
    try {
      const { postId } = req.params;
      const userId = req.user.id; // Mengambil ID user dari token
  
      // Cek apakah pengguna sudah memberi like pada post tersebut
      const like = await Like.findOne({ postId, userId });
  
      // Jika ditemukan, berarti sudah like, jika tidak berarti belum like
      res.status(200).json({ isLiked: like ? true : false });
    } catch (error) {
      res.status(500).json({ message: "Error checking like status", error });
    }
  };