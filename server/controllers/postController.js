import Post from "../models/Post.js";

export const createPost = async (req, res) => {
  try {
    const { urlMedia, textContent } = req.body;
    const newPost = new Post({
      urlMedia,
      textContent,
      postBy: req.user.id,
    });

    await newPost.save();
    res.status(201).json(newPost);
  } catch (error) {
    res.status(500).json({ message: "Error creating post", error });
    console.log(error)
  }
};

export const getPosts = async (req, res) => {
  try {
    const posts = await Post.find().populate("postBy", "nickname profilePict"); // Mengambil data user
    res.status(200).json(posts);
  } catch (error) {
    res.status(500).json({ message: "Error fetching posts", error });
  }
};

export const deletePost = async (req, res) => {
  try {
    const { id } = req.params;
    const post = await Post.findById(id);
    if (!post) return res.status(404).json({ message: "Post not found" });

    if (post.postBy.toString() !== req.user.id) {
      return res.status(403).json({ message: "Unauthorized action" });
    }

    await post.deleteOne();
    res.status(200).json({ message: "Post deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Error deleting post", error });
  }
};
