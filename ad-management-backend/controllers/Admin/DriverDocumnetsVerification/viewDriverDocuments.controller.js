const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const viewDriverDocuments = async (req, res) => {
  const { driverId } = req.params;

  try {
    const driverDocuments = await prisma.driverDocuments.findUnique({
      where: {
        driverId: driverId,
      },
      include: {
        driver: {
          select: {
            id: true,
            fullName: true,
            email: true,
            contactNumber: true,
            vehicleNumber: true,
            vehicleType: true,
          },
        },
      },
    });

    if (!driverDocuments) {
      return res.status(404).json({ error: 'Driver documents not found' });
    }

    res.status(200).json({ driverDocuments });
  } catch (error) {
    console.error('Error fetching driver documents:', error);
    res.status(500).json({ error: 'Something went wrong' });
  }
};

module.exports = { viewDriverDocuments };
