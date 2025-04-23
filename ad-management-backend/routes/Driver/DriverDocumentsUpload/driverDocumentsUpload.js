const express = require('express');
const router = express.Router();
const multer = require('multer');
const multerS3 = require('multer-s3');
const { S3Client } = require('@aws-sdk/client-s3');
const { v4: uuidv4 } = require('uuid');
const { saveDriverDocuments } = require('../../../controllers/DriverDocumentsUpload/driverDocumentsUpload.controller');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
require('dotenv').config();

const s3 = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

// Define folder map for each field
const folderMap = {
  photo: 'Drivers_Photo',
  idCard: 'Driver_ID_Card',
  drivingLicense: 'Driver_Driving_License',
  vehicleImage: 'Driver_Vehicle_Image',
  bankProof: 'Drivers_BankProof',
};

// Configure multer with S3 storage
const upload = multer({
  storage: multerS3({
    s3: s3,
    bucket: process.env.AWS_S3_BUCKET,
    contentType: multerS3.AUTO_CONTENT_TYPE,
  
    key: (req, file, cb) => {
      const field = file.fieldname;
      const folder = folderMap[field] || 'Others';
      const filename = `${uuidv4()}_${file.originalname}`;
      const fullPath = `Driver_Documents/${folder}/${filename}`;
      cb(null, fullPath);
    },
  }),
});

// Define the upload fields
const uploadFields = upload.fields([
  { name: 'photo', maxCount: 1 },
  { name: 'idCard', maxCount: 1 },
  { name: 'drivingLicense', maxCount: 1 },
  { name: 'vehicleImage', maxCount: 1 },
  { name: 'bankProof', maxCount: 1 },
]);

// POST route
router.post('/upload-driver-documents', uploadFields, saveDriverDocuments);

// GET route to check if a driver has submitted documents
router.get('/has-submitted-documents/:driverId', async (req, res) => {
  try {
    const { driverId } = req.params;

    const driverDocuments = await prisma.driverDocuments.findUnique({
      where: {
        driverId: driverId,
      },
    });

    const hasSubmitted = !!driverDocuments; // Convert to boolean

    return res.status(200).json({
      hasSubmitted,
      message: hasSubmitted 
        ? 'Driver has submitted documents' 
        : 'Driver has not submitted documents yet',
    });
  } catch (error) {
    console.error('Error checking driver documents:', error);
    return res.status(500).json({
      error: 'Something went wrong while checking documents',
    });
  }
});

// GET route to get driver document status
router.get('/document-status/:driverId', async (req, res) => {
  try {
    const { driverId } = req.params;

    const driverDocuments = await prisma.driverDocuments.findUnique({
      where: {
        driverId: driverId,
      },
    });

    if (!driverDocuments) {
      return res.status(404).json({
        error: 'Driver documents not found',
      });
    }

    return res.status(200).json({
      documents: driverDocuments,
    });
  } catch (error) {
    console.error('Error fetching driver document status:', error);
    return res.status(500).json({
      error: 'Something went wrong while fetching document status',
    });
  }
});

// PUT route to update a single document
router.put('/update-document/:driverId', upload.single('document'), async (req, res) => {
  try {
    const { driverId } = req.params;
    const { documentType } = req.fields || req.body; // Support both form data and JSON body
    
    if (!req.file) {
      return res.status(400).json({
        error: 'No document file provided',
      });
    }

    if (!documentType || !['photo', 'idCard', 'drivingLicense', 'vehicleImage', 'bankProof'].includes(documentType)) {
      return res.status(400).json({
        error: 'Invalid or missing document type',
      });
    }

    // Get the file location from S3
    const fileLocation = req.file.location;
    
    // Build the update object dynamically
    const updateData = {
      [`${documentType}Url`]: fileLocation,
      [`${documentType}Status`]: 'PENDING', // Reset status to pending for review
    };

    // Update only the specific document for this driver
    const updatedDocument = await prisma.driverDocuments.update({
      where: { driverId },
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
    return res.status(500).json({
      error: 'Something went wrong while updating the document',
    });
  }
});

module.exports = router;
