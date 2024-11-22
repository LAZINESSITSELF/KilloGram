import express from "express";
import { register, login, checkSession, getUserData, updateProfile } from "../controllers/authController.js";
import { verifyToken } from "../middleware/auth.js";

const router = express.Router();

router.post("/register", register);
router.post("/login", login);

router.put("/profile", verifyToken, updateProfile);

router.get("/checkSession", verifyToken, checkSession);
router.get("/user", verifyToken, getUserData);

export default router;
