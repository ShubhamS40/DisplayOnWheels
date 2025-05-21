const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

exports.uploadAdvertisementProof = async (req, res) => {
  try {
    const { campaignDriverId } = req.params;

    if (!req.file) {
      return res.status(400).json({
        status: 'error',
        message: 'No proof photo provided',
      });
    }

    // Check if campaign-driver record exists
    const campaignDriver = await prisma.campaignDriver.findUnique({
      where: { id: campaignDriverId },
    });

    if (!campaignDriver) {
      return res.status(404).json({
        status: 'error',
        message: 'Campaign assignment not found',
      });
    }

    // Get the uploaded file URL directly from multer-s3 (S3)
    const imageUrl = req.file.location;

    // Update campaignDriver table
    await prisma.campaignDriver.update({
      where: { id: campaignDriverId },
      data: {
        driverUploadAdvertisemntProofPhotoUrl: imageUrl,
        advertisementProofPhotoStatus: 'PENDING',
        isAdvertismentProofPhotoVerified: false,
      },
    });

    // Save in proofSubmission table
    await prisma.proofSubmission.create({
      data: {
        campaignId: campaignDriver.campaignId,
        campaignDriverId,
        imageUrl,
        status: 'PENDING',
      },
    });

    return res.status(200).json({
      status: 'success',
      message: 'Proof photo uploaded successfully',
      photoUrl: imageUrl,
    });
  } catch (err) {
    console.error('Upload Error:', err);
    return res.status(500).json({
      status: 'error',
      message: 'Server error',
    });
  }
};
