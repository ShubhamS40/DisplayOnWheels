const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

exports.getDriverProfile = async (req, res) => {
  const driverId = req.params.id;
console.log(driverId,"shubham");

  // Validate driver ID
  if (!driverId) {
    return res.status(400).json({ 
      success: false, 
      message: 'Driver ID is required' 
    });
  }

  try {
    // Use select instead of include for more efficient queries
    // Only get the fields we actually need
    const driver = await prisma.driverRegistration.findUnique({
      where: { id: driverId },
      select: {
        // Basic details
        id: true,
        fullName: true,
        email: true,
        contactNumber: true,
        isEmailVerified: true,
        isAvailable: true,
        walletBalance: true,
        createdAt: true,
        updatedAt: true,
        
        // Vehicle details
        vehicleType: true,
        vehicleNumber: true,
        
        // Documents & bank details through relation
        documents: {
          select: {
            photoUrl: true,
            idCardUrl: true,
            drivingLicenseUrl: true,
            vehicleImageUrl: true,
            bankProofUrl: true,
            
            // Document statuses
            photoStatus: true,
            idCardStatus: true,
            drivingLicenseStatus: true,
            vehicleImageStatus: true,
            bankProofStatus: true,
            verificationStatus: true,
            adminMessage: true,
            
            // Bank details
            branchName: true,
            bankName: true,
            ifscCode: true,
            accountNumber: true
          }
        },
        
        // Campaigns
        campaignDrivers: {
          select: {
            campaignId: true,
            status: true,
            assignedAt: true,
            driverUploadAdvertisemntProofPhotoUrl: true,
            earnings: true,
            campaign: {
              select: {
                title: true,
                status: true
              }
            }
          }
        }
      }
    });

    if (!driver) {
      return res.status(404).json({ 
        success: false, 
        message: 'Driver not found' 
      });
    }

    // Organize response in a structured format
    const response = {
      success: true,
      message: 'Driver profile fetched successfully',
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
          updatedAt: driver.updatedAt
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
            profilePhoto: driver.documents.photoStatus,
            idCard: driver.documents.idCardStatus,
            drivingLicense: driver.documents.drivingLicenseStatus,
            vehicleImage: driver.documents.vehicleImageStatus,
            bankProof: driver.documents.bankProofStatus,
            overall: driver.documents.verificationStatus,
            adminMessage: driver.documents.adminMessage || null
          }
        } : null,
        bankDetails: driver.documents ? {
          branchName: driver.documents.branchName,
          bankName: driver.documents.bankName,
          ifscCode: driver.documents.ifscCode,
          accountNumber: driver.documents.accountNumber
        } : null,
        campaigns: driver.campaignDrivers.map(cd => ({
          id: cd.campaignId,
          title: cd.campaign.title,
          campaignStatus: cd.campaign.status,
          driverStatus: cd.status,
          assignedAt: cd.assignedAt,
          proofPhoto: cd.driverUploadAdvertisemntProofPhotoUrl || null,
          earnings: cd.earnings
        }))
      }
    };

    return res.status(200).json(response);
  } catch (error) {
    console.error('Error fetching driver profile:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch driver profile',
      error: process.env.NODE_ENV === 'production' ? 'Server error' : error.message
    });
  }
};