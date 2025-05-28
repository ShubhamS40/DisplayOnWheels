const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const getVerifiedCompanyList = async (req, res) => {
  try {
    const companies = await prisma.companyRegistration.findMany({
      where: {
        isEmailVerified: true,
        documents: {
          verificationStatus: "APPROVED"
        }
      },
      select: {
        id: true,
        businessName: true,
        email: true
      }
    });

    return res.status(200).json({
      success: true,
      message: "Verified company list fetched successfully",
      data: companies
    });
  } catch (error) {
    console.error("Error fetching companies:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch companies",
      error: error.message
    });
  }
};

module.exports = {
  getVerifiedCompanyList
};
