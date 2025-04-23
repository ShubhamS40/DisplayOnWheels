const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const verifyDriverDocuments = async (req, res) => {
  const { driverId } = req.params;
  const {
    photoStatus,
    idCardStatus,
    drivingLicenseStatus,
    vehicleImageStatus,
    bankProofStatus,
    adminMessage, // optional
  } = req.body;

  try {
    const existing = await prisma.driverDocuments.findUnique({
      where: { driverId },
    });

    if (!existing) {
      return res.status(404).json({ error: 'Driver documents not found' });
    }

    // 🔍 Check if all documents are approved
    const allApproved = [
      photoStatus,
      idCardStatus,
      drivingLicenseStatus,
      vehicleImageStatus,
      bankProofStatus,
    ].every(status => status === 'APPROVED');

    const verificationStatus = allApproved ? 'APPROVED' : 'REJECTED';
    const finalAdminMessage = allApproved ? null : (adminMessage || 'Some documents are not valid. Please review and re-upload.');

    const updated = await prisma.driverDocuments.update({
      where: { driverId },
      data: {
        photoStatus,
        idCardStatus,
        drivingLicenseStatus,
        vehicleImageStatus,
        bankProofStatus,
        verificationStatus,
        adminMessage: finalAdminMessage,
      },
    });

    res.status(200).json({
      message: 'Document statuses updated successfully',
      updatedDocuments: updated,
    });

  } catch (error) {
    console.error('Error updating documents:', error);
    res.status(500).json({ error: 'Something went wrong' });
  }
};

module.exports = { verifyDriverDocuments };
