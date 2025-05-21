const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Get all pending advertisement proof photos with details
exports.getAllPendingProofs = async (req, res) => {
  try {
    const pendingProofs = await prisma.campaignDriver.findMany({
      where: {
        advertisementProofPhotoStatus: 'PENDING',
        driverUploadAdvertisemntProofPhotoUrl: { not: null },
      },
      select: {
        id: true,
        driverUploadAdvertisemntProofPhotoUrl: true,
        driver: {
          select: {
            fullName: true,
            vehicleNumber: true,
          },
        },
        campaign: {
          select: {
            title: true,
            company: {
              select: {
                businessName: true,
              },
            },
          },
        },
        assignedAt: true,
      },
    });

    res.json({ success: true, data: pendingProofs });
  } catch (error) {
    console.error('Error fetching proofs:', error);
    res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// Approve advertisement proof photo
exports.approveProof = async (req, res) => {
  const { campaignDriverId, adminId } = req.body;

  try {
    await prisma.campaignDriver.update({
      where: { id: campaignDriverId },
      data: {
        isAdvertismentProofPhotoVerified: true,
        advertisementProofPhotoStatus: 'APPROVED',
        advertisementProofPhotoAdminId: adminId,
        advertisementProofPhotoAdminMessage: null,
      },
    });

    res.json({ success: true, message: 'Proof approved successfully' });
  } catch (error) {
    console.error('Error approving proof:', error);
    res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// Reject advertisement proof photo
exports.rejectProof = async (req, res) => {
  const { campaignDriverId, adminId, message } = req.body;

  try {
    await prisma.campaignDriver.update({
      where: { id: campaignDriverId },
      data: {
        isAdvertismentProofPhotoVerified: false,
        advertisementProofPhotoStatus: 'REJECTED',
        advertisementProofPhotoAdminId: adminId,
        advertisementProofPhotoAdminMessage: message,
        driverUploadAdvertisemntProofPhotoUrl: null, // Ask for reupload
      },
    });

    res.json({ success: true, message: 'Proof rejected and driver notified to reupload' });
  } catch (error) {
    console.error('Error rejecting proof:', error);
    res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};
