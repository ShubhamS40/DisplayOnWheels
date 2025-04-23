const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const saveDriverDocuments = async (req, res) => {
  try {
    console.log("Request body:", req.body);
    console.log("Files received:", req.files ? Object.keys(req.files).length : 0);
    
    const {
      driverId,
      branchName,
      bankName,
      ifscCode,
      accountNumber,
    } = req.body;

    const files = req.files;

    // Validate required fields
    if (!driverId) {
      return res.status(400).json({ error: 'Driver ID is required' });
    }
    
    if (!files || !files.photo || !files.idCard || !files.drivingLicense || 
        !files.vehicleImage || !files.bankProof) {
      return res.status(400).json({ error: 'All document files are required' });
    }

    // Helper function to get S3 URL from file
    const getS3Url = (file) => {
      // Check if we have location (older AWS SDK) or key is set directly
      if (file.location) {
        return file.location;
      } 
      
      // For newer AWS SDK
      return `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${file.key}`;
    };

    // Get S3 URLs for all files
    const photoUrl = getS3Url(files.photo[0]);
    const idCardUrl = getS3Url(files.idCard[0]);
    const drivingLicenseUrl = getS3Url(files.drivingLicense[0]);
    const vehicleImageUrl = getS3Url(files.vehicleImage[0]);
    const bankProofUrl = getS3Url(files.bankProof[0]);

    console.log("Creating record with driver ID:", driverId);
    
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

    console.log("Documents saved successfully:", driverDoc.id);
    res.status(200).json({ message: 'Documents uploaded', data: driverDoc });
  } catch (err) {
    console.error('Error saving driver documents:', err);
    res.status(500).json({ error: `Server error: ${err.message}` });
  }
};

module.exports = { saveDriverDocuments };
