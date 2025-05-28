// controllers/campaignController.js
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Get campaign details with allocated drivers for company dashboard
exports.getCompanyCampaignDetails = async (req, res) => {
  const { campaignId } = req.params;

  try {
    // Get campaign with all related information
    const campaign = await prisma.campaign.findUnique({
      where: {
        id: campaignId  // Use as String
      },
      include: {
        company: true,
        plan: true,
        campaignDrivers: {
          include: {
            driver: true
          }
        }
      }
    });

    if (!campaign) {
      return res.status(404).json({ message: 'Campaign not found' });
    }

    // Format response data
    const formattedData = {
      campaign: {
        id: campaign.id,
        title: campaign.title,
        startDate: campaign.startDate,
        endDate: campaign.endDate,
        approvalStatus: campaign.approvalStatus,
        posterUrl: campaign.posterFile
          ? `${req.protocol}://${req.get('host')}/uploads/posters/${campaign.posterFile}`
          : null,
        allocatedDriversCount: campaign.campaignDrivers.length,
        description: campaign.description || 'No description provided',
        createdAt: campaign.createdAt
      },
      company: {
        id: campaign.company.id,
        name: campaign.company.businessName
      },
      plan: campaign.plan
        ? {
            id: campaign.plan.id,
            name: campaign.plan.title,
            description: campaign.plan.subtitle
          }
        : null,
 allocatedDrivers: campaign.campaignDrivers.map(allocation => {
 
  return {
    id: allocation.driver.id,
    name: allocation.driver.fullName,
    vehicleNumber: allocation.driver.vehicleNumber || 'N/A',
    phone: allocation.driver.contactNumber,
    status: allocation.status || 'Active',
    lastActive: allocation.lastActiveAt,
    currentLocation: allocation.driver.currentLocation
      ? typeof allocation.driver.currentLocation === 'string'
        ? JSON.parse(allocation.driver.currentLocation)
        : allocation.driver.currentLocation
      : null,
    assignedAt: allocation.assignedAt,
    advertisementProofVerified: allocation.isAdvertismentProofPhotoVerified,
    AddProofPhoto:
      allocation.isAdvertismentProofPhotoVerified === true
        ? allocation.driverUploadAdvertisemntProofPhotoUrl
        : null
  };
})



    };

    res.status(200).json(formattedData);
  } catch (error) {
    console.error('Error fetching campaign details:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Get all campaigns for a company with status filter
exports.getCompanyCampaigns = async (req, res) => {
  const { companyId } = req.params;
  const { status } = req.query; // 'active', 'pending', 'completed'

  try {
    // Build filter conditions
    const where = { companyId };

    // Add status filtering
    if (status === 'active') {
      where.approvalStatus = 'APPROVED';
      where.endDate = { gt: new Date() };
    } else if (status === 'pending') {
      where.approvalStatus = 'PENDING';
    } else if (status === 'completed') {
      where.approvalStatus = 'APPROVED';
      where.endDate = { lte: new Date() };
    }

    // Get campaigns with basic info
    const campaigns = await prisma.campaign.findMany({
      where,
      include: {
        plan: {
          select: {
            title: true
          }
        },
        campaignDrivers: {
          select: {
            driverId: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    // Calculate remaining days for active campaigns
    const formattedCampaigns = campaigns.map(campaign => {
      let validity = null;

      if (campaign.approvalStatus === 'APPROVED' && campaign.endDate > new Date()) {
        const today = new Date();
        const endDate = new Date(campaign.endDate);
        const diffTime = Math.abs(endDate - today);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        validity = diffDays;
      }

      return {
        id: campaign.id,
        name: campaign.title,
        startDate: campaign.startDate,
        endDate: campaign.endDate,
        posterUrl: campaign.posterFile
          ? `${req.protocol}://${req.get('host')}/uploads/posters/${campaign.posterFile}`
          : null,
        approvalStatus: campaign.approvalStatus,
        description: campaign.description || 'No description provided',  
        planName: campaign.plan?.title || 'Basic Plan',
        validity: validity !== null ? `${validity} days left` : null,
        carsCount: campaign.campaignDrivers.length
      };
    });

    res.status(200).json(formattedCampaigns);
  } catch (error) {
    console.error('Error fetching campaigns:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Get details of a driver with their campaign proof uploads
exports.getDriverDetails = async (req, res) => {
  const { driverId, campaignId } = req.params;

  try {
    // Get driver details with campaign assignment
    const driverAssignment = await prisma.campaignDriver.findUnique({
      where: {
        campaignId_driverId: {
          campaignId: campaignId,
          driverId: driverId
        }
      },
      include: {
        driver: true,
        campaign: true
      }
    });

    if (!driverAssignment) {
      return res.status(404).json({ message: 'Driver assignment not found' });
    }

    // Format the response
    const driverDetails = {
      id: driverAssignment.driver.id,
      name: driverAssignment.driver.fullName,
      vehicleNumber: driverAssignment.driver.vehicleNumber || 'N/A',
      phone: driverAssignment.driver.contactNumber,
      status: driverAssignment.status || 'Active',
      lastActive: driverAssignment.lastActiveAt,
      location: driverAssignment.lastLocation ? JSON.parse(driverAssignment.lastLocation) : null,
      assignedAt: driverAssignment.assignedAt,
      uploadedImages: driverAssignment.proofImages ? JSON.parse(driverAssignment.proofImages) : []
    };

    res.status(200).json(driverDetails);
  } catch (error) {
    console.error('Error fetching driver details:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};
