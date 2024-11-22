import jwt from 'jsonwebtoken';

const verifyToken = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1]; // Ambil token dari header

    if (!token) {
        return res.status(403).json({ message: "Token is required" }); // Token tidak ditemukan
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(401).json({ message: "Invalid or expired token" }); // Token tidak valid atau kadaluarsa
        }
        req.user = decoded;  // Menyimpan data user yang sudah didecode ke req.user
        next();  // Lanjutkan ke route berikutnya
    });
};

export { verifyToken };