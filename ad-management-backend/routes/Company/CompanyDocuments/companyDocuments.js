const express = require('express');
const router = express.Router();
const multer = require('multer');
const multerS3 = require('multer-s3');
const { S3Client } = require('@aws-sdk/client-s3');
const { v4: uuidv4 } = require('uuid');
const { PrismaClient } = require('@prisma/client');
const { saveCompanyDocuments } = require('../../../controllers/Company/CompanyDocumnetUpload/companyDocumentsUpload.controller');
const prisma = new PrismaClient();
require('dotenv').config();

const s3 = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

// Folder map
const folderMap = {
  companyRegistrationDoc: 'Company_Registration_Documents',
  idCard: 'Company_ID_Card',
  gstNumberDoc: 'Company_GST_Documents',
};


const upload = multer({
  storage: multerS3({
    s3: s3,
    bucket: process.env.AWS_S3_BUCKET,
    contentType: multerS3.AUTO_CONTENT_TYPE,
    key: (req, file, cb) => {
      const field = file.fieldname;
      const folder = folderMap[field] || 'Others';
      const filename = `${uuidv4()}_${file.originalname}`;
      const fullPath = `Company_Documents/${folder}/${filename}`;
      cb(null, fullPath);
    },
  }),
});

// Upload fields

  const uploadFields = upload.fields([
    { name: 'companyRegistrationDoc', maxCount: 1 },
    { name: 'idCard', maxCount: 1 },
    { name: 'gstNumberDoc', maxCount: 1 },
  ]);
  


// POST: Upload company documents
router.post('/upload-company-documents', uploadFields, saveCompanyDocuments);


// GET: Check if company has submitted documents
router.get('/has-submitted-documents/:companyId', async (req, res) => {
  try {
    const { companyId } = req.params;
    const companyDocuments = await prisma.companyDocuments.findUnique({
      where: { companyId },
    });

    const hasSubmitted = !!companyDocuments;

    return res.status(200).json({
      hasSubmitted,
      message: hasSubmitted
        ? 'Company has submitted documents'
        : 'Company has not submitted documents yet',
    });
  } catch (error) {
    console.error('Error checking company documents:', error);
    return res.status(500).json({ error: 'Error checking documents' });
  }
});

// GET: Get document status
router.get('/document-status/:companyId', async (req, res) => {
  try {
    const { companyId } = req.params;
    const companyDocuments = await prisma.companyDocuments.findUnique({
      where: { companyId },
    });

    if (!companyDocuments) {
      return res.status(404).json({ error: 'Company documents not found' });
    }

    return res.status(200).json({ documents: companyDocuments });
  } catch (error) {
    console.error('Error fetching company document status:', error);
    return res.status(500).json({ error: 'Error fetching document status' });
  }
});

// PUT: Update a single document
router.put('/update-document/:companyId', upload.single('document'), async (req, res) => {
  try {
    const { companyId } = req.params;
    const { documentType } = req.body;

    if (!req.file) {
      return res.status(400).json({ error: 'No document file provided' });
    }

    if (!documentType || !['companyRegistration', 'idCard', 'gstNumber'].includes(documentType)) {
      return res.status(400).json({ error: 'Invalid or missing document type' });
    }

    const fileLocation = req.file.location;

    // Prepare update data using correct Prisma field names
    const fieldMap = {
      companyRegistration: 'companyRegistrationUrl',
      idCard: 'idCardUrl',
      gstNumber: 'gstNumberUrl',
    };

    const statusFieldMap = {
      companyRegistration: 'companyRegistrationStatus',
      idCard: 'idCardStatus',
      gstNumber: 'gstNumberStatus',
    };

    const updateData = {
      [fieldMap[documentType]]: fileLocation,
      [statusFieldMap[documentType]]: 'PENDING',
    };

    const updatedDocument = await prisma.companyDocuments.update({
      where: { companyId },
      data: updateData,
    });

    return res.status(200).json({
      message: 'Document updated successfully',
      document: {
        type: documentType,
        url: fileLocation,
        status: 'PENDING',
      },
    });
  } catch (error) {
    console.error('Error updating document:', error);
    return res.status(500).json({ error: 'Error updating document' });
  }
});

module.exports = router;
