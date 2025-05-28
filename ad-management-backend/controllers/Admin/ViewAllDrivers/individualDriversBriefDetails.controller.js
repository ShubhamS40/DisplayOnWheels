const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();


// Get full driver details by ID
exports.getDriverDetailsById = async (req, res) => {
  const driverId = req.params.id;

  if (!driverId) {
    return res.status(400).json({ success: false, message: "Driver ID is required" });
  }

  try {
    const driver = await prisma.driverRegistration.findUnique({
      where: { id: driverId },
      select: {
        id: true,
        fullName: true,
        email: true,
        contactNumber: true,
        isEmailVerified: true,
        isAvailable: true,
        walletBalance: true,
        vehicleType: true,
        vehicleNumber: true,
        currentLocation: true,
        createdAt: true,
        updatedAt: true,
        documents: {
          select: {
            photoUrl: true,
            idCardUrl: true,
            drivingLicenseUrl: true,
            vehicleImageUrl: true,
            bankProofUrl: true,
            photoStatus: true,
            idCardStatus: true,
            drivingLicenseStatus: true,
            vehicleImageStatus: true,
            bankProofStatus: true,
            verificationStatus: true,
            adminMessage: true,
            branchName: true,
            bankName: true,
            ifscCode: true,
            accountNumber: true
          }
        },
        campaignDrivers: {
          select: {
            status: true,
            assignedAt: true,
            earnings: true,
            driverUploadAdvertisemntProofPhotoUrl: true,
            campaign: {
              select: {
                id: true,
                title: true,
                status: true,
                company: {
                  select: {
                    id: true,
                    businessName: true,
                    email: true
                  }
                }
              }
            }
          }
        }
      }
    });

    if (!driver) {
      return res.status(404).json({ success: false, message: 'Driver not found' });
    }

    res.status(200).json({
      success: true,
      message: "Driver details fetched successfully",
      data: {
        basicDetails: {
          id: driver.id,
          fullName: driver.fullName,
          email: driver.email,
          contactNumber: driver.contactNumber,
          isEmailVerified: driver.isEmailVerified,
          isAvailable: driver.isAvailable,
          walletBalance: driver.walletBalance,
          createdAt: driver.createdAt,
          updatedAt: driver.updatedAt,
          currentLocation: driver.currentLocation
        },
        vehicleDetails: {
          vehicleType: driver.vehicleType,
          vehicleNumber: driver.vehicleNumber
        },
        documentDetails: driver.documents ? {
          photos: {
            profilePhoto: driver.documents.photoUrl,
            idCard: driver.documents.idCardUrl,
            drivingLicense: driver.documents.drivingLicenseUrl,
            vehicleImage: driver.documents.vehicleImageUrl,
            bankProof: driver.documents.bankProofUrl
          },
          verificationStatus: {
            photo: driver.documents.photoStatus,
            idCard: driver.documents.idCardStatus,
            drivingLicense: driver.documents.drivingLicenseStatus,
            vehicleImage: driver.documents.vehicleImageStatus,
            bankProof: driver.documents.bankProofStatus,
            overall: driver.documents.verificationStatus,
            adminMessage: driver.documents.adminMessage
          },
          bank: {
            branchName: driver.documents.branchName,
            bankName: driver.documents.bankName,
            ifscCode: driver.documents.ifscCode,
            accountNumber: driver.documents.accountNumber
          }
        } : null,
        assignedCampaigns: driver.campaignDrivers.map(cd => ({
          status: cd.status,
          assignedAt: cd.assignedAt,
          earnings: cd.earnings,
          proofPhotoUrl: cd.driverUploadAdvertisemntProofPhotoUrl,
          campaign: {
            id: cd.campaign.id,
            title: cd.campaign.title,
            status: cd.campaign.status,
            company: cd.campaign.company
          }
        }))
      }
    });
  } catch (error) {
    console.error('Error fetching driver details:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch driver details',
      error: error.message
    });
  }
};
