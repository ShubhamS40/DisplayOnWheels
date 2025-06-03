const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

exports.getCompanyProfile = async (req, res) => {
  const companyId = req.params.id;
  console.log(companyId, "Fetching company profile");

  if (!companyId) {
    return res.status(400).json({
      success: false,
      message: 'Company ID is required'
    });
  }

  try {
    const company = await prisma.companyRegistration.findUnique({
      where: { id: companyId },
      select: {
        id: true,
        businessName: true,
        businessType: true,
        email: true,
        contactNumber: true,
        isEmailVerified: true,
        walletBalance: true,
        createdAt: true,
        updatedAt: true,

        // Company documents
        documents: {
          select: {
            companyRegistrationUrl: true,
            idCardUrl: true,
            gstNumberUrl: true,

            companyName: true,
            companyType: true,
            companyAddress: true,
            companyCity: true,
            companyState: true,
            companyCountry: true,
            companyZipCode: true,

            companyRegistrationStatus: true,
            idCardStatus: true,
            gstNumberStatus: true,
            verificationStatus: true,
            adminMessage: true
          }
        },

        // Related campaigns
        campaigns: {
          select: {
            id: true,
            title: true,
            status: true,
            totalAmount: true,
            approvalStatus: true,
            startDate: true,
            endDate: true,
            vehicleCount: true,
            posterFile: true,
            posterDesignNeeded: true,
            approvedAt: true
          }
        },

        // Payments
        payments: {
          select: {
            id: true,
            amount: true,
            status: true,
            paymentMethod: true,
            transactionId: true,
            refunded: true,
            refundReason: true,
            refundedAt: true,
            paymentProof: true,
            createdAt: true
          }
        }
      }
    });

    if (!company) {
      return res.status(404).json({
        success: false,
        message: 'Company not found'
      });
    }

    const response = {
      success: true,
      message: 'Company profile fetched successfully',
      data: {
        basicDetails: {
          id: company.id,
          businessName: company.businessName,
          businessType: company.businessType,
          email: company.email,
          contactNumber: company.contactNumber,
          isEmailVerified: company.isEmailVerified,
          walletBalance: company.walletBalance,
          createdAt: company.createdAt,
          updatedAt: company.updatedAt
        },
        documentDetails: company.documents ? {
          urls: {
            registrationDoc: company.documents.companyRegistrationUrl,
            idCard: company.documents.idCardUrl,
            gstNumber: company.documents.gstNumberUrl
          },
          companyInfo: {
            name: company.documents.companyName,
            type: company.documents.companyType,
            address: company.documents.companyAddress,
            city: company.documents.companyCity,
            state: company.documents.companyState,
            country: company.documents.companyCountry,
            zipCode: company.documents.companyZipCode
          },
          verificationStatus: {
            registrationStatus: company.documents.companyRegistrationStatus,
            idCardStatus: company.documents.idCardStatus,
            gstStatus: company.documents.gstNumberStatus,
            overall: company.documents.verificationStatus,
            adminMessage: company.documents.adminMessage || null
          }
        } : null,
        campaigns: company.campaigns.map(c => ({
          id: c.id,
          title: c.title,
          status: c.status,
          approvalStatus: c.approvalStatus,
          totalAmount: c.totalAmount,
          startDate: c.startDate,
          endDate: c.endDate,
          vehicleCount: c.vehicleCount,
          posterFile: c.posterFile,
          posterDesignNeeded: c.posterDesignNeeded,
          approvedAt: c.approvedAt
        })),
        payments: company.payments.map(p => ({
          id: p.id,
          amount: p.amount,
          status: p.status,
          method: p.paymentMethod,
          transactionId: p.transactionId,
          refunded: p.refunded,
          refundReason: p.refundReason,
          refundedAt: p.refundedAt,
          proof: p.paymentProof,
          date: p.createdAt
        }))
      }
    };

    return res.status(200).json(response);

  } catch (error) {
    console.error('Error fetching company profile:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch company profile',
      error: process.env.NODE_ENV === 'production' ? 'Server error' : error.message
    });
  }
};
