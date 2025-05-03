const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const registerAdmin = async (req, res) => {
  try {
    const { name, email, password, confirmPassword } = req.body;

    // 1. Validate required fields
    if (!name || !email || !password || !confirmPassword) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    if (password !== confirmPassword) {
      return res.status(400).json({ error: 'Passwords do not match' });
    }

    // 2. Check for existing email
    const existingAdmin = await prisma.admin.findUnique({
      where: { email },
    });

    if (existingAdmin) {
      return res.status(409).json({ error: 'Email is already registered' });
    }

    // 3. Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // 4. Generate OTP and expiration
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // 5. Create admin account
    const admin = await prisma.admin.create({
      data: {
        name,
        email,
        password: hashedPassword,
        otp,
        otpExpires,
        isEmailVerified: false,
      },
    });

    // 6. Configure and send email
    const transporter = nodemailer.createTransport({
      service: 'Gmail',
      auth: {
        user: 'info.displayonwheels@gmail.com',
        pass: 'pjuq ybwp eysq cwlg', // ideally use environment variables
      },
    });

    await transporter.sendMail({
      from: `"Admin App" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Verify Your Admin Account',
      text: `Hello ${name},\n\nYour OTP code is: ${otp}.\n\nThis code will expire in 10 minutes.\n\nThank you!`,
    });

    // 7. Respond to client
    res.status(201).json({
      message: 'Admin registered successfully. Please verify your email using the OTP sent.',
      adminId: admin.id,
      email: admin.email,
    });

  } catch (error) {
    console.error('Error during admin registration:', error);
    res.status(500).json({ error: 'Server error. Please try again later.' });
  }
};

module.exports = { registerAdmin };
