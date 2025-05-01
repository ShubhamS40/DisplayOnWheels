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

// Verify Company Email
const verifyCompanyEmail = async (req, res) => {
  try {
    const { companyEmail, otp } = req.body;

    if (!companyEmail || !otp) {
      return res.status(400).json({ error: 'Company email and OTP are required' });
    }

    const company = await prisma.companyRegistration.findUnique({
      where: { email: companyEmail }, // ✅ corrected field name
    });

    if (!company) {
      return res.status(404).json({ error: 'Company not found' });
    }

    if (company.isEmailVerified) {
      return res.status(400).json({ error: 'Email already verified' });
    }

    if (company.otp !== otp) {
      return res.status(400).json({ error: 'Invalid OTP' });
    }

    if (company.otpExpires < new Date()) {
      return res.status(400).json({ error: 'OTP has expired' });
    }

    await prisma.companyRegistration.update({
      where: { email: companyEmail }, // ✅ corrected field name
      data: {
        isEmailVerified: true,
        otp: null,
        otpExpires: null,
      },
    });

    res.status(200).json({ message: 'Company email verified successfully' });
  } catch (error) {
    console.error('Company email verification error:', error);
    res.status(500).json({ error: 'Server error. Try again later.' });
  }
};

// Resend OTP
const resendCompanyOtp = async (req, res) => {
  try {
    const { companyEmail } = req.body;

    if (!companyEmail) {
      return res.status(400).json({ error: 'Company email is required' });
    }

    const company = await prisma.companyRegistration.findUnique({
      where: { email: companyEmail }, // ✅ corrected field name
    });

    if (!company) {
      return res.status(404).json({ error: 'Company not found' });
    }

    if (company.isEmailVerified) {
      return res.status(400).json({ error: 'Email already verified' });
    }

    const newOtp = generateOTP();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    await prisma.companyRegistration.update({
      where: { email: companyEmail }, // ✅ corrected field name
      data: {
        otp: newOtp,
        otpExpires,
      },
    });

    // Send OTP via email
    await transporter.sendMail({
      from: 'info.displayonwheels@gmail.com',
      to: companyEmail,
      subject: 'Your New OTP for Company Verification',
      text: `Your new OTP is: ${newOtp}. It will expire in 10 minutes.`,
    });

    res.status(200).json({ message: 'Company OTP resent successfully' });
  } catch (error) {
    console.error('Resend Company OTP error:', error);
    res.status(500).json({ error: 'Server error. Try again later.' });
  }
};

module.exports = {
  verifyCompanyEmail,
  resendCompanyOtp,
};
