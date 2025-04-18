// controllers/Driver/driverForgotPassword.controller.js

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient({
  log: ['query', 'info', 'warn', 'error'], // Add this for better debugging
});
const crypto = require('crypto');
const nodemailer = require('nodemailer');

const forgotPasswordDriver = async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ error: 'Email is required.' });
  }

  try {
    // First test database connectivity
    console.log("Testing database connection...");
    
    try {
      // Simple query to test connection
      await prisma.$queryRaw`SELECT 1`;
      console.log("Database connection successful");
    } catch (connErr) {
      console.error("Database connection failed:", connErr);
      return res.status(500).json({ error: 'Database connection error. Please try again later.' });
    }
    
    // Continue with your original code
    const driver = await prisma.driverRegistration.findUnique({
      where: { email: email }
    });
    
    console.log("Driver found:", driver);

    if (!driver || !driver.email) {
      return res.status(404).json({ error: 'Driver not found or email missing.' });
    }

    // Rest of your code remains the same...
    const token = crypto.randomBytes(32).toString('hex');
    const expiration = new Date(Date.now() + 1000 * 60 * 15); // 15 minutes

    await prisma.driverRegistration.update({
      where: { id: driver.id },
      data: {
        passwordResetToken: token,
        passwordResetExpires: expiration,
      }
    });

    const resetLink = `http://localhost:3000/reset-password/${token}`;

    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: 'info.displayonwheels@gmail.com',
        pass: 'pjuq ybwp eysq cwlg',
      }
    });

    await transporter.sendMail({
      from: `"Driver Support" info.displayonwheels@gmail.com`,
      to: driver.email,
      subject: 'Reset Your Password',
      html: `<p>Click below to reset your password:</p>
             <a href="${resetLink}">${resetLink}</a>
             <p>This link will expire in 15 minutes.</p>`
    }, (err, info) => {
        if (err) return console.error('Error:', err);
        console.log('Sent:', info.response);
      });

    return res.status(200).json({ message: 'Password reset link sent to your email.' });

  } catch (err) {
    console.error('Forgot Password Error:', err);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};

module.exports = { forgotPasswordDriver };