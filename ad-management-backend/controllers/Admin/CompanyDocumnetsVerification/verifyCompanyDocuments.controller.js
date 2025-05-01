const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const verifyCompanyDocuments = async (req, res) => {
  const { companyId } = req.params;
  const {
    companyRegistrationStatus,
    idCardStatus,
    gstNumberStatus,
    adminMessage, // optional
  } = req.body;

  try {
    const existing = await prisma.companyDocuments.findUnique({
      where: { companyId },
    });

    if (!existing) {
      return res.status(404).json({ error: 'Company documents not found' });
    }

    // 🔍 Check if all documents are approved
    const allApproved = [
      companyRegistrationStatus,
      idCardStatus,
      gstNumberStatus,
    ].every(status => status === 'APPROVED');

    const verificationStatus = allApproved ? 'APPROVED' : 'REJECTED';
    const finalAdminMessage = allApproved ? null : (adminMessage || 'Some documents are not valid. Please review and re-upload.');

    const updated = await prisma.companyDocuments.update({
      where: { companyId },
      data: {
        companyRegistrationStatus,
        idCardStatus,
        gstNumberStatus,
        verificationStatus,
        adminMessage: finalAdminMessage,
      },
    });

    res.status(200).json({
      message: 'Company document statuses updated successfully',
      updatedDocuments: updated,
    });

  } catch (error) {
    console.error('Error updating company documents:', error);
    res.status(500).json({ error: 'Something went wrong while verifying company documents.' });
  }
};

module.exports = { verifyCompanyDocuments };
