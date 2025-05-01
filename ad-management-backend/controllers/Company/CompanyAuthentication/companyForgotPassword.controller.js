const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient({
  log: ['query', 'info', 'warn', 'error'],
});
const crypto = require('crypto');
const nodemailer = require('nodemailer');

const forgotPasswordCompany = async (req, res) => {
  const { email } = req.body;
   console.log(email);
   
  if (!email) {
    return res.status(400).json({ error: 'Email is required.' });
  }

  try {
    // Check DB connection
    console.log("Testing database connection...");
    try {
      await prisma.$queryRaw`SELECT 1`;
      console.log("Database connection successful");
    } catch (connErr) {
      console.error("Database connection failed:", connErr);
      return res.status(500).json({ error: 'Database connection error. Please try again later.' });
    }

    // Find company by email
    const company = await prisma.companyRegistration.findUnique({
      where: { email }
    });

    console.log("Company found:", company);

    if (!company || !company.email) {
      return res.status(404).json({ error: 'Company not found or email missing.' });
    }

    // Generate token
    const token = crypto.randomBytes(32).toString('hex');
    const expiration = new Date(Date.now() + 1000 * 60 * 15); // 15 minutes

    // Update company with token
    await prisma.companyRegistration.update({
      where: { id: company.id },
      data: {
        passwordResetToken: token,
        passwordResetExpires: expiration,
      }
    });

    // Prepare reset link
    const resetLink = `http://localhost:3000/reset-company-password/${token}`;

    // Send email
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: 'info.displayonwheels@gmail.com',
        pass: 'pjuq ybwp eysq cwlg',
      }
    });

    await transporter.sendMail({
      from: `"Company Support" <info.displayonwheels@gmail.com>`,
      to: company.email,
      subject: 'Reset Your Company Account Password',
      html: `<p>Click below to reset your password:</p>
             <a href="${resetLink}">${resetLink}</a>
             <p>This link will expire in 15 minutes.</p>`
    }, (err, info) => {
      if (err) return console.error('Error sending email:', err);
      console.log('Email sent:', info.response);
    });

    return res.status(200).json({ message: 'Password reset link sent to your email.' });

  } catch (err) {
    console.error('Company Forgot Password Error:', err);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};

module.exports = { forgotPasswordCompany };
