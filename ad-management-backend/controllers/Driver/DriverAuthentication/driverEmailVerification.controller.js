const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const nodemailer = require('nodemailer');

// OTP generator
const generateOTP = () => Math.floor(100000 + Math.random() * 900000).toString();

// Nodemailer transporter (hardcoded credentials)
const transporter = nodemailer.createTransport({
  service: 'Gmail',
  auth: {
    user: 'info.displayonwheels@gmail.com',
    pass: 'pjuq ybwp eysq cwlg', // App password
  },
});

const verifyEmail = async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ error: 'Email and OTP are required' });
    }

    const driver = await prisma.driverRegistration.findUnique({
      where: { email },
    });

    if (!driver) {
      return res.status(404).json({ error: 'Driver not found' });
    }

    if (driver.isEmailVerified) {
      return res.status(400).json({ error: 'Email already verified' });
    }

    if (driver.otp !== otp) {
      return res.status(400).json({ error: 'Invalid OTP' });
    }

    if (driver.otpExpires < new Date()) {
      return res.status(400).json({ error: 'OTP has expired' });
    }

    await prisma.driverRegistration.update({
      where: { email },
      data: {
        isEmailVerified: true,
        otp: null,
        otpExpires: null,
      },
    });

    res.status(200).json({ message: 'Email verified successfully' });
  } catch (error) {
    console.error('OTP verification error:', error);
    res.status(500).json({ error: 'Server error. Try again later.' });
  }
};

const resendOtp = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    const driver = await prisma.driverRegistration.findUnique({
      where: { email },
    });

    if (!driver) {
      return res.status(404).json({ error: 'Driver not found' });
    }

    if (driver.isEmailVerified) {
      return res.status(400).json({ error: 'Email already verified' });
    }

    const newOtp = generateOTP();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    await prisma.driverRegistration.update({
      where: { email },
      data: {
        otp: newOtp,
        otpExpires,
      },
    });

    // Send OTP via email
    await transporter.sendMail({
      from: 'info.displayonwheels@gmail.com',
      to: email,
      subject: 'Your New OTP for Driver Verification',
      text: `Your new OTP is: ${newOtp}. It will expire in 10 minutes.`,
    });

    res.status(200).json({ message: 'OTP resent successfully' });
  } catch (error) {
    console.error('Resend OTP error:', error);
    res.status(500).json({ error: 'Server error. Try again later.' });
  }
};

module.exports = {
  verifyEmail,
  resendOtp,
};
