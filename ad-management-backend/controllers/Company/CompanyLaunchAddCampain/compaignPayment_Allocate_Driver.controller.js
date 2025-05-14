// payment.controller.js
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const validateAndRecordPayment = async (req, res) => {
  const { campaignId, companyId, amount, status, paymentMethod, transactionId, paymentProof } = req.body;

  try {
    // Validate campaign & company existence
    const [campaign, company] = await Promise.all([
      prisma.campaign.findUnique({ where: { id: campaignId } }),
      prisma.companyRegistration.findUnique({ where: { id: companyId } })
    ]);

    if (!campaign || !company) {
      return res.status(404).json({ error: 'Campaign or Company not found' });
    }

    // Record payment
    const payment = await prisma.payment.create({
      data: {
        campaignId,
        companyId,
        amount,
        status,
        paymentMethod,
        transactionId,
        paymentProof
      }
    });

    // Update campaign status if payment successful
    if (status === 'SUCCESS') {
      await prisma.campaign.update({
        where: { id: campaignId },
        data: { status: 'PAID' }
      });
    }

    res.json({ success: true, message: 'Payment recorded', payment });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Payment processing failed' });
  }
};


// campaignDriver.controller.js
const assignDriversToCampaign = async (req, res) => {
  const { driverIds, assignedById } = req.body;
  const campaignId = req.params.id;

  try {
    // Check if campaign exists
    const campaign = await prisma.campaign.findUnique({
      where: { id: campaignId }
    });
    if (!campaign) {
      return res.status(404).json({ error: 'Campaign not found' });
    }

    // Assign drivers to the campaign
    const assignments = await Promise.all(
      driverIds.map(driverId =>
        prisma.campaignDriver.upsert({
          where: {
            campaignId_driverId: {
              campaignId,
              driverId
            }
          },
          update: {
            assignedById,
            assignedAt: new Date()
          },
          create: {
            campaignId,
            driverId,
            assignedById
          }
        })
      )
    );

    // Mark assigned drivers as unavailable
    await prisma.driverRegistration.updateMany({
      where: {
        id: { in: driverIds }
      },
      data: {
        isAvailable: false
      }
    });

    res.json({
      success: true,
      message: 'Drivers assigned successfully',
      assignedDrivers: assignments
    });
  } catch (err) {
    console.error('Error assigning drivers to campaign:', err);
    res.status(500).json({ error: 'Driver assignment failed' });
  }
};


// campaign.controller.js
const getCampaignWithDrivers = async (req, res) => {
  const { id } = req.params;

  try {
    const campaign = await prisma.campaign.findUnique({
      where: { id },
      include: {
        campaignDrivers: {
          include: {
            driver: true
          }
        },
        payments: true
      }
    });

    if (!campaign) return res.status(404).json({ error: 'Campaign not found' });

    res.json({ success: true, campaign });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch campaign details' });
  }
};

module.exports = {
  validateAndRecordPayment,
  assignDriversToCampaign,
  getCampaignWithDrivers
};