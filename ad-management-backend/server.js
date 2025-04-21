const express = require('express');
const multer = require('multer');
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

const app = express();
const upload = multer({ storage: multer.memoryStorage() });

const s3 = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

app.post('/upload', upload.single('image'), async (req, res) => {
  const file = req.file;

  if (!file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  const fileExtension = file.originalname.split('.').pop();
  const filename = `uploads/${uuidv4()}.${fileExtension}`;

  const command = new PutObjectCommand({
    Bucket: process.env.AWS_S3_BUCKET,
    Key: filename,
    Body: file.buffer,
    ContentType: file.mimetype,
  });

  try {
    await s3.send(command);
    const imageUrl = `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${filename}`;

    res.status(200).json({
      message: 'File uploaded successfully',
      imageUrl,
    });
  } catch (error) {
    console.error('Upload failed:', error);
    res.status(500).json({ error: 'Upload failed' });
  }
});

app.listen(5000, () => {
  console.log('🚀 Server is running on port 5000');
});
