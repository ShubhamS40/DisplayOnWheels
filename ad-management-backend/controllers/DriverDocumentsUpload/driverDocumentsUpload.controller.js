const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const saveDriverDocuments = async (req, res) => {
  try {
    const {
      driverId,
      branchName,
      bankName,
      ifscCode,
      accountNumber,
    } = req.body;

    const files = req.files;

    // S3 folder prefixes
    const photoUrl = files.photo[0].location.replace(
      files.photo[0].key,
      `Driver_Documents/Drivers_Photo/${files.photo[0].key.split('/').pop()}`
    );
    const idCardUrl = files.idCard[0].location.replace(
      files.idCard[0].key,
      `Driver_Documents/Driver_ID_Card/${files.idCard[0].key.split('/').pop()}`
    );
    const drivingLicenseUrl = files.drivingLicense[0].location.replace(
      files.drivingLicense[0].key,
      `Driver_Documents/Driver_Driving_License/${files.drivingLicense[0].key.split('/').pop()}`
    );
    const vehicleImageUrl = files.vehicleImage[0].location.replace(
      files.vehicleImage[0].key,
      `Driver_Documents/Driver_Vehicle_Image/${files.vehicleImage[0].key.split('/').pop()}`
    );
    const bankProofUrl = files.bankProof[0].location.replace(
      files.bankProof[0].key,
      `Driver_Documents/Drivers_BankProof/${files.bankProof[0].key.split('/').pop()}`
    );

    const driverDoc = await prisma.driverDocuments.upsert({
      where: { driverId },
      update: {
        photoUrl,
        idCardUrl,
        drivingLicenseUrl,
        vehicleImageUrl,
        bankProofUrl,
        branchName,
        bankName,
        ifscCode,
        accountNumber,
      },
      create: {
        driverId,
        photoUrl,
        idCardUrl,
        drivingLicenseUrl,
        vehicleImageUrl,
        bankProofUrl,
        branchName,
        bankName,
        ifscCode,
        accountNumber,
      },
    });

    res.status(200).json({ message: 'Documents uploaded', data: driverDoc });
  } catch (err) {
    console.error('Error saving driver documents:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

module.exports = { saveDriverDocuments };
