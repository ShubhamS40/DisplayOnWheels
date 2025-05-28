// controllers/driverController.js

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const getVerifiedDrivers = async (req, res) => {
  try {
    const drivers = await prisma.driverRegistration.findMany({
      where: {
        isEmailVerified: true,
      },
      select: {
        id: true,
        fullName: true,  // or email: true if you prefer email
        email: true
      },
    });

    res.status(200).json({
      success: true,
      data: drivers,
    });
  } catch (error) {
    console.error('Error fetching verified drivers:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
};

module.exports = {
  getVerifiedDrivers,
};
