const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const nodemailer = require('nodemailer');

// OTP generator
const generateOTP = () => Math.floor(100000 + Math.random() * 900000).toString();

// Nodemailer transporter
const transporter = nodemailer.createTransport({
  service: 'Gmail',
  auth: {
    user: 'info.displayonwheels@gmail.com',
    pass: 'pjuq ybwp eysq cwlg', // App password
  },
});

// Verify Admin Email
const verifyAdminEmail = async (req, res) => {
  try {
    const { adminEmail, otp } = req.body;

    if (!adminEmail || !otp) {
      return res.status(400).json({ error: 'Admin email and OTP are required' });
    }

    const admin = await prisma.admin.findUnique({
      where: { email: adminEmail },
    });

    if (!admin) {
      return res.status(404).json({ error: 'Admin not found' });
    }

    if (admin.isEmailVerified) {
      return res.status(400).json({ error: 'Email already verified' });
    }

    if (admin.otp !== otp) {
      return res.status(400).json({ error: 'Invalid OTP' });
    }

    if (admin.otpExpires < new Date()) {
      return res.status(400).json({ error: 'OTP has expired' });
    }

    await prisma.admin.update({
      where: { email: adminEmail },
      data: {
        isEmailVerified: true,
        otp: null,
        otpExpires: null,
      },
    });

    res.status(200).json({ message: 'Admin email verified successfully' });
  } catch (error) {
    console.error('Admin email verification error:', error);
    res.status(500).json({ error: 'Server error. Try again later.' });
  }
};

// Resend OTP
const resendAdminOtp = async (req, res) => {
  try {
    const { adminEmail } = req.body;

    if (!adminEmail) {
      return res.status(400).json({ error: 'Admin email is required' });
    }

    const admin = await prisma.admin.findUnique({
      where: { email: adminEmail },
    });

    if (!admin) {
      return res.status(404).json({ error: 'Admin not found' });
    }

    if (admin.isEmailVerified) {
      return res.status(400).json({ error: 'Email already verified' });
    }

    const newOtp = generateOTP();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    await prisma.admin.update({
      where: { email: adminEmail },
      data: {
        otp: newOtp,
        otpExpires,
      },
    });

    // Send OTP via email
    await transporter.sendMail({
      from: 'info.displayonwheels@gmail.com',
      to: adminEmail,
      subject: 'Your New OTP for Admin Verification',
      text: `Your new OTP is: ${newOtp}. It will expire in 10 minutes.`,
    });

    res.status(200).json({ message: 'Admin OTP resent successfully' });
  } catch (error) {
    console.error('Resend Admin OTP error:', error);
    res.status(500).json({ error: 'Server error. Try again later.' });
  }
};

module.exports = {
  verifyAdminEmail,
  resendAdminOtp,
};
