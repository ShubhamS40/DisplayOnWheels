const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const saveCompanyDocuments = async (req, res) => {
  try {
    console.log("Request body:", req.body);
    console.log("Files received:", req.files ? Object.keys(req.files) : 'No files');

    const {
      companyId,
      companyName,
      companyType,
      companyAddress,
      companyCity,
      companyState,
      companyCountry,
      companyZipCode,
    } = req.body;

    const files = req.files;

    // Validate required fields
    if (!companyId) {
      return res.status(400).json({ error: 'Company ID is required' });
    }

    if (
      !files ||
      !files.companyRegistrationDoc ||
      !files.idCard ||
      !files.gstNumberDoc
    ) {
      return res.status(400).json({ error: 'All document files are required' });
    }

    // Helper function to get S3 URL or fallback
    const getS3Url = (file) => {
      return file.location || `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${file.key}`;
    };

    // Get S3 URLs
    const companyRegistrationUrl = getS3Url(files.companyRegistrationDoc[0]);
    const idCardUrl = getS3Url(files.idCard[0]);
    const gstNumberUrl = getS3Url(files.gstNumberDoc[0]);

    console.log("Saving company documents for ID:", companyId);

    // Build update and create data objects
    const updateData = {
      companyName,
      companyType,
      companyAddress,
      companyRegistrationUrl,
      idCardUrl,
      gstNumberUrl,
    };
    const createData = {
      companyId,
      companyName,
      companyType,
      companyAddress,
      companyRegistrationUrl,
      idCardUrl,
      gstNumberUrl,
      companyRegistrationStatus: "PENDING",
      idCardStatus: "PENDING",
      gstNumberStatus: "PENDING",
      verificationStatus: "PENDING",
    };

    // Add optional fields if provided
    if (companyCity) {
      updateData.companyCity = companyCity;
      createData.companyCity = companyCity;
    }
    if (companyState) {
      updateData.companyState = companyState;
      createData.companyState = companyState;
    }
    if (companyCountry) {
      updateData.companyCountry = companyCountry;
      createData.companyCountry = companyCountry;
    }
    if (companyZipCode) {
      updateData.companyZipCode = companyZipCode;
      createData.companyZipCode = companyZipCode;
    }

    const companyDoc = await prisma.companyDocuments.upsert({
      where: { companyId },
      update: updateData,
      create: createData,
    });

    console.log("Company documents saved:", companyDoc.id);
    res.status(200).json({ message: 'Company documents uploaded', data: companyDoc });
  } catch (err) {
    console.error("Error saving company documents:", err);
    res.status(500).json({ error: `Server error: ${err.message}` });
  }
};

module.exports = { saveCompanyDocuments };
