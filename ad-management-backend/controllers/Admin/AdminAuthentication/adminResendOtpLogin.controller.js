const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const crypto = require('crypto');
const nodemailer = require('nodemailer');

const resendLoginAdminOtp = async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ msg: 'Email is required' });
  }

  try {
    const admin = await prisma.admin.findUnique({
      where: { email },
    });

    if (!admin) {
      return res.status(400).json({ msg: 'Admin not found' });
    }

    // Generate new OTP (6-digit random number)
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes from now

    // Update admin record with new OTP and expiry
    await prisma.admin.update({
      where: { id: admin.id },
      data: {
        otp,
        otpExpires,
      },
    });

    // Configure your email transporter (example uses Gmail)
    const transporter = nodemailer.createTransport({
      service: 'Gmail',
      auth: {
        user: process.env.EMAIL_USER, // set in .env
        pass: process.env.EMAIL_PASS, // set in .env
      },
    });

    // Send OTP email
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: admin.email,
      subject: 'Your Admin Login OTP',
      text: `Your OTP for admin login is: ${otp}. It will expire in 10 minutes.`,
    });

    return res.status(200).json({ msg: 'OTP resent successfully' });
  } catch (err) {
    console.error('Resend Admin OTP Error:', err);
    return res.status(500).json({ msg: 'Internal Server Error' });
  }
};

module.exports = { resendLoginAdminOtp };
