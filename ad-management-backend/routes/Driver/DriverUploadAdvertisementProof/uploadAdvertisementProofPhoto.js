const express = require('express');
const router = express.Router();
const multer = require('multer');
const multerS3 = require('multer-s3');
const { S3Client } = require('@aws-sdk/client-s3');
const { v4: uuidv4 } = require('uuid');
const path = require('path');
const { uploadAdvertisementProof } = require('../../../controllers/Driver/DriverUploadAdvertisemntProof/uploadAdvertisementProof.controller');

// Configure S3 client
const s3 = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

// Multer S3 storage config for advertisement proof
const upload = multer({
  storage: multerS3({
    s3: s3,
    bucket: process.env.AWS_S3_BUCKET,
    contentType: multerS3.AUTO_CONTENT_TYPE,
    key: (req, file, cb) => {
      // Customize S3 key (path + filename)
      const filename = `${uuidv4()}${path.extname(file.originalname)}`;
      const key = `DriverCampaignAdvertismentProofPhoto/${filename}`;
      cb(null, key);
    },
  }),
});

// POST route: Upload proof photo directly to S3
router.post(
  '/upload-advertisement-proof-photo/:campaignDriverId',
  upload.single('photo'),
  uploadAdvertisementProof
);

module.exports = router;
