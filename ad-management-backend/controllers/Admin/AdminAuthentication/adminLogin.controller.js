const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const { validationResult } = require('express-validator');
const nodemailer = require('nodemailer');
const crypto = require('crypto');

const prisma = new PrismaClient();

// Setup nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'info.displayonwheels@gmail.com',
    pass: 'pjuq ybwp eysq cwlg', // app password
  },
});

// Helper: Generate 6-digit OTP
const generateOTP = () => Math.floor(100000 + Math.random() * 900000).toString();

const adminLogin = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { email, password } = req.body;

  try {
    const admin = await prisma.admin.findUnique({
      where: { email },
    });

    if (!admin) {
      return res.status(400).json({ msg: 'Admin not found' });
    }

    if (!admin.isEmailVerified) {
      return res.status(400).json({ msg: 'Please verify your email before logging in' });
    }

    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    // Generate OTP
    const otp = generateOTP();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 min expiry

    // Save OTP in admin record
    await prisma.admin.update({
      where: { id: admin.id },
      data: {
        otp,
        otpExpires,
      },
    });

    // Send OTP by email
    await transporter.sendMail({
      from: '"Admin Support" <info.displayonwheels@gmail.com>',
      to: admin.email,
      subject: 'Your Admin Login OTP',
      text: `Your OTP is ${otp}. It will expire in 10 minutes.`,
    });

    res.status(200).json({
      msg: 'OTP sent to your email. Please verify to complete login.',
    });
  } catch (err) {
    console.error('Server Error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
};

module.exports = { adminLogin };
