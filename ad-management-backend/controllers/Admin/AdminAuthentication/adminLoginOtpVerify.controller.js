const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const adminVerifyOtp = async (req, res) => {
  const { email, otp } = req.body;

  // Validate inputs
  if (!email || !otp) {
    return res.status(400).json({ msg: 'Email and OTP are required' });
  }

  try {
    // Check if admin exists
    const admin = await prisma.admin.findUnique({
      where: { email },
    });

    if (!admin) {
      return res.status(400).json({ msg: 'Admin not found' });
    }

    // Check if OTP is correct and not expired
    if (admin.otp !== otp || admin.otpExpires < new Date()) {
      return res.status(400).json({ msg: 'Invalid or expired OTP' });
    }

    // Clear OTP after successful verification
    await prisma.admin.update({
      where: { id: admin.id },
      data: {
        otp: null,
        otpExpires: null,
      },
    });

    // Create JWT payload
    const payload = {
      adminId: admin.id,
      name: admin.name,
      email: admin.email,
      role: 'admin',
    };

    // Sign JWT
    jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' }, (err, token) => {
      if (err) {
        console.error('Error signing token', err);
        return res.status(500).json({ msg: 'Server error' });
      }
      // Send JWT token as response
      res.json({ token });
    });
  } catch (err) {
    console.error('Server Error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
};

module.exports = { adminVerifyOtp };
