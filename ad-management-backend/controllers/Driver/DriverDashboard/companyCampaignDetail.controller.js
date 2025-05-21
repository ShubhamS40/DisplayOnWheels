const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

exports.getDriverCampaigns = async (req, res) => {
  try {
    const { driverId } = req.params;

    if (!driverId) {
      return res.status(400).json({
        status: 'error',
        message: 'Driver ID is required',
      });
    }

    const campaigns = await prisma.campaignDriver.findMany({
      where: { driverId },
      include: {
        driver: {
          include: {
            documents: true,
          },
        },
        campaign: {
          include: {
            plan: true,
            company: {
              include: {
                documents: true,
              },
            },
          },
        },
      },
      orderBy: {
        assignedAt: 'desc',
      },
    });

    return res.status(200).json({
      status: 'success',
      data: campaigns,
    });
  } catch (error) {
    console.error('Error fetching driver campaigns:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to fetch driver campaigns',
      error: error.message,
    });
  }
};
