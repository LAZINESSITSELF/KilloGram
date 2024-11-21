import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    nickname: { type: String, default: () => `User${Math.floor(Math.random() * 10000)}` },
    profilePict: { type: String, default: "" },
    location: { type: String, default: "" },
    interest: { type: [String], default: [] },
    birthday: { type: Date, required: false },
    note: { type: String, default: "" },
    status: { type: String, default: "offline" },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    createdOn: { type: Date, default: Date.now },
    updatedOn: { type: Date, default: Date.now },
});

const User = mongoose.model("User", userSchema);
export default User;
