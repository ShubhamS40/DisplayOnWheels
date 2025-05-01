const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Get all companies with verificationStatus PENDING or REJECTED and at least one document PENDING or REJECTED
const getPendingCompanies = async (req, res) => {
  try {
    const pendingCompanies = await prisma.companyDocuments.findMany({
      where: {
        verificationStatus: {
          in: ['PENDING', 'REJECTED'],
        },
        OR: [
          { companyRegistrationStatus: { not: 'APPROVED' } },
          { idCardStatus: { not: 'APPROVED' } },
          { gstNumberStatus: { not: 'APPROVED' } },
        ],
      },
      include: {
        company: {
          select: {
            id: true,
            businessName: true,
            businessType: true,
            email: true,
            contactNumber: true,
            isEmailVerified: true,
          },
        },
      },
    });

    console.log(pendingCompanies);

    res.status(200).json({ companies: pendingCompanies });
  } catch (error) {
    console.error('Error fetching pending companies:', error);
    res.status(500).json({ error: 'Something went wrong while fetching pending companies.' });
  }
};

module.exports = {
  getPendingCompanies,
};
