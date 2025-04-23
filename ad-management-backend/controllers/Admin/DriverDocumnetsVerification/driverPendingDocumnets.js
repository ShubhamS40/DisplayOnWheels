const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Get all drivers with verificationStatus PENDING or REJECTED and at least one document PENDING
const getPendingDrivers = async (req, res) => {
  try {
    const pendingDrivers = await prisma.driverDocuments.findMany({
        where: {
            verificationStatus: {
              in: ['PENDING', 'REJECTED'],
            },
            OR: [
              { photoStatus: { not: 'APPROVED' } },
              { idCardStatus: { not: 'APPROVED' } },
              { drivingLicenseStatus: { not: 'APPROVED' } },
              { vehicleImageStatus: { not: 'APPROVED' } },
              { bankProofStatus: { not: 'APPROVED' } },
            ],
          }
,          
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

    console.log(pendingDrivers);

    res.status(200).json({ drivers: pendingDrivers });
  } catch (error) {
    console.error('Error fetching pending drivers:', error);
    res.status(500).json({ error: 'Something went wrong while fetching pending drivers.' });
  }
};

module.exports = {
  getPendingDrivers,
};
