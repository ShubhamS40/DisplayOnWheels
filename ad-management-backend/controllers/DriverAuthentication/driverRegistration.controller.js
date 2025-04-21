const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const registerDriver = async (req, res) => {
  try {
    const {
      fullName,
      email,
      contactNumber,
      vehicleType,
      vehicleNumber,
      password,
      confirmPassword,
      acceptedTerms,
    } = req.body;

    // Validate required fields
    if (
      !fullName ||
      !email ||
      !contactNumber ||
      !vehicleType ||
      !vehicleNumber ||
      !password ||
      !confirmPassword
    ) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    if (password !== confirmPassword) {
      return res.status(400).json({ error: 'Passwords do not match' });
    }

    if (!acceptedTerms) {
      return res.status(400).json({ error: 'You must accept the Terms & Conditions' });
    }

    // Check for existing email
    const existingDriver = await prisma.driverRegistration.findUnique({
      where: { email },
    });

    if (existingDriver) {
      return res.status(409).json({ error: 'Email is already registered' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Generate OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // expires in 10 minutes

    // Create the driver with OTP fields
    const driver = await prisma.driverRegistration.create({
      data: {
        fullName,
        email,
        contactNumber,
        vehicleType,
        vehicleNumber,
        password: hashedPassword,
        acceptedTerms: true,
        otp,
        otpExpires,
        isEmailVerified: false,
      },
    });

    // ✉️ Email Configuration and Sending
    const transporter = nodemailer.createTransport({
      service: 'Gmail', // or 'Outlook', 'Yahoo', etc.
      auth: {
        user: 'info.displayonwheels@gmail.com',
        pass: 'pjuq ybwp eysq cwlg',
      },
    });

    await transporter.sendMail({
      from: `"Driver App" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Verify Your Email',
      text: `Hello ${fullName},\n\nYour OTP code is: ${otp}.\n\nThis code will expire in 10 minutes.\n\nThanks!`,
    });

    res.status(201).json({
      message: 'Driver registered successfully. Please verify your email using the OTP sent.',
      driverId: driver.id,
      email: driver.email,
    });
  } catch (error) {
    console.error('Error during registration:', error);
    res.status(500).json({ error: 'Server error. Try again later.' });
  }
};

module.exports = { registerDriver };
