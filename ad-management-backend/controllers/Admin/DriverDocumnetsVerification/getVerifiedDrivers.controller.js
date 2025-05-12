// driverController.js
const { PrismaClient } = require('@prisma/client');
const asyncHandler = require('express-async-handler');
const prisma = new PrismaClient();

// Get all verified drivers available for assignment
exports.getVerifiedDrivers = asyncHandler(async (req, res) => {
  try {
    // Query for drivers with verified (APPROVED) documents
    const verifiedDrivers = await prisma.driverRegistration.findMany({
      where: {
        documents: {
          verificationStatus: 'APPROVED'  // Make sure we're checking the right field for verification
        }
      },
      select: {
        id: true,
        fullName: true,
        email: true,
        contactNumber: true,
        vehicleType: true,
        vehicleNumber: true,
        currentLocation: true,
        documents: {
          select: {
            id: true,
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
            adminMessage: true
          }
        },
        campaignDrivers: {
          select: {
            campaignId: true,
            assignedAt: true,
            campaign: {
              select: {
                title: true,
                startDate: true,
                endDate: true
              }
            }
          },
          where: {
            campaign: {
              OR: [
                { endDate: { gt: new Date() } },
                { endDate: null }
              ]
            }
          }
        }
      }
    });

    res.json({
      success: true,
      count: verifiedDrivers.length,
      data: verifiedDrivers
    });
  } catch (error) {
    console.error('Error fetching verified drivers:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve verified drivers',
      error: error.message
    });
  }
});


// Additional function to get drivers available for specific campaigns
// This takes into account location, vehicle type, and existing assignments
exports.getDriversWithoutCampaign = asyncHandler(async (req, res) => {
  try {
    const availableDrivers = await prisma.driverRegistration.findMany({
      where: {
        isAvailable: true,
        documents: {
          verificationStatus: 'APPROVED'
        }
      },
      select: {
        id: true,
        fullName: true,
        vehicleType: true,
        vehicleNumber: true,
        currentLocation: true
      }
    });

    res.json({
      success: true,
      count: availableDrivers.length,
      data: availableDrivers
    });
  } catch (error) {
    console.error('Error fetching available drivers:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve available drivers',
      error: error.message
    });
  }
});
