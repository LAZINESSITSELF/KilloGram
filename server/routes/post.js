import express from "express";
import { verifyToken } from "../middleware/auth.js";
import { createPost, getPosts, deletePost } from "../controllers/postController.js";
import { likePost, unlikePost, getLikes, getLikeStatus } from "../controllers/likeController.js";

const router = express.Router();

// Routes untuk postingan
router.post("/", verifyToken, createPost);
router.get("/", getPosts);
router.delete("/:id", verifyToken, deletePost);

// Routes untuk like/unlike postingan
router.post("/like/:postId", verifyToken, likePost);
router.delete("/unlike/:postId", verifyToken, unlikePost);
router.get("/likes/:postId", verifyToken, getLikes);
router.get("/getLikeStatus/:postId", verifyToken, getLikeStatus)

export default router;