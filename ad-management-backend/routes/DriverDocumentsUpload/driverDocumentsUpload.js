const express = require('express');
const router = express.Router();
const multer = require('multer');
const multerS3 = require('multer-s3');
const { S3Client } = require('@aws-sdk/client-s3');
const { v4: uuidv4 } = require('uuid');
const { saveDriverDocuments } = require('../../controllers/DriverDocumentsUpload/driverDocumentsUpload.controller');
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

module.exports = router;
