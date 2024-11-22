import mongoose from "mongoose";

const postSchema = new mongoose.Schema({
  urlMedia: {
    type: String,
    default: null, // Gambar atau video, opsional
  },
  textContent: {
    type: String,
    default: null, // Teks konten opsional
  },
  likeCount: {
    type: Number,
    default: 0, // Default jumlah like
  },
  commentCount: {
    type: Number,
    default: 0, // Default jumlah komentar
  },
  postBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User", // Referensi ke user yang membuat postingan
    required: true,
  },
  createdOn: {
    type: Date,
    default: Date.now, // Waktu pembuatan postingan
  },
  updatedOn: {
    type: Date,
    default: Date.now, // Waktu terakhir pembaruan
  },
});

const Post = mongoose.model("Post", postSchema);

export default Post;
