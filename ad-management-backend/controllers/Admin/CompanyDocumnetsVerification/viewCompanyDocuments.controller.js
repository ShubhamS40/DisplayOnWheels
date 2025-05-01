const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const viewCompanyDocuments = async (req, res) => {
  const { companyId } = req.params;

  try {
    const companyDocuments = await prisma.companyDocuments.findUnique({
      where: {
        companyId: companyId,
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

    if (!companyDocuments) {
      return res.status(404).json({ error: 'Company documents not found' });
    }

    res.status(200).json({ companyDocuments });
  } catch (error) {
    console.error('Error fetching company documents:', error);
    res.status(500).json({ error: 'Something went wrong while fetching company documents.' });
  }
};

module.exports = { viewCompanyDocuments };
