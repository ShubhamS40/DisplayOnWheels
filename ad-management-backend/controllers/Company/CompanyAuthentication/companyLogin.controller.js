const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const { validationResult } = require('express-validator');

const prisma = new PrismaClient();

const companyLogin = async (req, res) => {
  // Validate request body
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { email, password } = req.body;

  try {
    // Check if company exists
    const company = await prisma.companyRegistration.findUnique({
      where: { email },
    });

    if (!company) {
      return res.status(400).json({ msg: 'Company not found' });
    }

    // Optional: Check if email is verified
    if (!company.isEmailVerified) {
      return res.status(403).json({ msg: 'Please verify your email before logging in' });
    }

    // Compare passwords
    const isMatch = await bcrypt.compare(password, company.password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    // Create JWT payload
    const payload = {
      companyId: company.id,
      businessName: company.businessName,
      email: company.email,
    };

    // Sign and send JWT
    jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' }, (err, token) => {
      if (err) {
        console.error('JWT sign error:', err);
        return res.status(500).json({ msg: 'Server error' });
      }
      res.json({ token });
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
};

module.exports = { companyLogin };
