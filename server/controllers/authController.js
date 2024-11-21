import User from "../models/User.js";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

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
        const user = req.user; // Data pengguna dari middleware
        res.status(200).json({ message: "Session valid", user });
    } catch (error) {
        res.status(500).json({ message: "Server error", error });
    }
};
