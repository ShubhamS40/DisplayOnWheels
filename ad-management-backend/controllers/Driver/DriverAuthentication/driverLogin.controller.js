const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const { validationResult } = require('express-validator');

const prisma = new PrismaClient(); // Import your Prisma client
const driverLogin = async (req, res) => {
  // Check for validation errors (if any)
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { email, password } = req.body;

  try {
    // Check if driver exists with the given email using Prisma
    const driver = await prisma.driverRegistration.findUnique({
      where: {
        email: email
      }
    });

    if (!driver) {
      return res.status(400).json({ msg: 'Driver not found' });
    }

    // Compare password with the hashed password stored in the database
    const isMatch = await bcrypt.compare(password, driver.password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    // Create JWT payload
    const payload = {
      driverId: driver.id, // Assuming driver ID is 'id' in your schema
      name: driver.name,
      email: driver.email,
    };

    // Sign JWT and send it back as a response
    jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' }, (err, token) => {
      if (err) {
        console.error('Error signing token', err);
        return res.status(500).json({ msg: 'Server error' });
      }
      res.json({ token });
    });
  } catch (err) {
    console.error('Server Error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
};

module.exports = {driverLogin};
