import express from "express";
import { verifyToken } from "../middleware/auth.js";
import { addComment, getComments, updateComment, deleteComment } from "../controllers/commentController.js";

const router = express.Router();

router.post("/add", verifyToken, addComment);
router.get("/:postId", verifyToken, getComments);
router.put("/update/:commentId", verifyToken, updateComment);
router.delete("/delete/:commentId", verifyToken, deleteComment);

export default router;