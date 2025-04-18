const bcrypt = require('bcryptjs');
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

    // Create the driver
    const driver = await prisma.driverRegistration.create({
      data: {
        fullName,
        email,
        contactNumber,
        vehicleType,
        vehicleNumber,
        password: hashedPassword,
        acceptedTerms: true,
      },
    });

    res.status(201).json({
      message: 'Driver registered successfully',
      driver: {
        id: driver.id,
        fullName: driver.fullName,
        email: driver.email,
      },
    });
  } catch (error) {
    console.error('Error during registration:', error);
    res.status(500).json({ error: 'Server error. Try again later.' });
  }
};

module.exports = { registerDriver };
