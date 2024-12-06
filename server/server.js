import express from "express";
import http from "http";
import dotenv from "dotenv";
import { Server } from "socket.io";
import connectDB from "./config/db.js";
import authRoutes from "./routes/auth.js";
import postRoutes from "./routes/post.js";
import commentRoutes from "./routes/comment.js"

dotenv.config();

const app = express();
const server = http.createServer(app);  // Gunakan server HTTP
const io = new Server(server, {
  cors: {
    origin: "*",  // Pastikan CORS diatur untuk memungkinkan koneksi dari frontend
  }
});

// Middleware
app.use(express.json());

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/posts", postRoutes);
app.use("/api/comment", commentRoutes)

io.on("connection", (socket) => {
  console.log("A user connected");
  socket.on("disconnect", () => {
    console.log("A user disconnected");
  });
});

// Menangani pengiriman notifikasi
const sendLikeNotification = (userId, postId) => {
  io.emit("likeNotification", { userId, postId });
};

// Database connection
connectDB();

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
