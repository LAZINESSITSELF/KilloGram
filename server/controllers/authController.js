import User from "../models/User.js";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { verifyToken } from "../middleware/auth.js";

const generateRandomNickname = () => {
    const animals = [
        "Lion", "Tiger", "Bear", "Eagle", "Wolf", "Fox", "Panther",
        "Hawk", "Shark", "Falcon", "Otter", "Penguin", "Cheetah"
    ];
    const randomAnimal = animals[Math.floor(Math.random() * animals.length)];
    const randomNumber = Math.floor(1000 + Math.random() * 9000); // 4 digit
    return `${randomAnimal}${randomNumber}`;
};


export const register = async (req, res) => {
    try {
        const { username, email, birthday, password } = req.body;

        // Validasi input
        if (!username || !email || !birthday || !password) {
            return res.status(400).json({ message: "All fields are required: username, email, birthday, password." });
        }

        // Periksa jika username atau email sudah digunakan
        const existingUser = await User.findOne({ $or: [{ username }, { email }] });
        if (existingUser) {
            return res.status(400).json({ message: "Username or email already taken." });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Buat user baru
        const user = await User.create({
            username,
            email,
            birthday,
            password: hashedPassword,
            nickname: generateRandomNickname(),
            profilePict: null,
            location: null,
            interest: [],
            note: null,
            status: "offline",
            createdOn: new Date(),
            updatedOn: new Date(),
        });

        res.status(201).json({ message: "User registered successfully", user });
    } catch (error) {
        res.status(500).json({ message: "Server error", error });
    }
};


export const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ message: "Email and password are required." });
        }

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: "User not found." });
        }

        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            return res.status(401).json({ message: "Invalid password." });
        }

        // Generate JWT
        const token = jwt.sign({ id: user._id, username: user.username }, process.env.JWT_SECRET, {
            expiresIn: "1d", // Token berlaku selama 1 hari
        });

        res.status(200).json({ message: "Login successful", token });
    } catch (error) {
        res.status(500).json({ message: "Server error", error });
    }
};

export const checkSession = async (req, res) => {
    try {
        // Ambil data user dari req.user yang sudah didecode di middleware
        const user = req.user;

        // Kembalikan respon sukses dengan data user
        res.status(200).json({ message: "Session valid", user });
    } catch (error) {
        res.status(500).json({ message: "Server error", error });
    }
};

export const getUserData = async (req, res) => {
    try {
        const user = await User.findById(req.user.id);  // Ambil data pengguna berdasarkan ID dari token
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        // Kembalikan data pengguna
        res.status(200).json({
            username: user.username,
            nickname: user.nickname,
            profilePict: user.profilePict,
            email: user.email,
            location: user.location,
            interest: user.interest,
            birthday: user.birthday,
        });
    } catch (error) {
        res.status(500).json({ message: "Server error", error });
    }
};

export const updateProfile = async (req, res) => {
    try {
        const { username, nickname, location, interest, profilePict } = req.body;
        const userId = req.user.id; // Mengambil user ID dari token yang sudah diverifikasi

        // Update user data di database
        const updatedUser = await User.findByIdAndUpdate(
            userId,
            {
                username: username || undefined,
                nickname: nickname || undefined,
                location: location || undefined,
                interest: interest || undefined,
                profilePict: profilePict || undefined, // Gambar profil baru jika ada
                updatedOn: new Date(),
            },
            { new: true } // Agar hasil yang dikembalikan adalah user yang sudah diperbarui
        );

        if (!updatedUser) {
            return res.status(404).json({ message: "User not found" });
        }

        res.status(200).json({ message: "Profile updated successfully", user: updatedUser });
    } catch (error) {
        res.status(500).json({ message: "Error updating profile", error });
    }
};