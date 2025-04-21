const AWS = require('aws-sdk');
const multer = require('multer');
const multerS3 = require('multer-s3');

// ✅ Update with your actual credentials or use environment variables
AWS.config.update({
  accessKeyId: 'YOUR_AWS_ACCESS_KEY_ID',
  secretAccessKey: 'YOUR_AWS_SECRET_ACCESS_KEY',
  region: 'YOUR_AWS_REGION',
});

const s3 = new AWS.S3();

const upload = multer({
  storage: multerS3({
    s3,
    bucket: 'displayonwheel',
    // ✅ REMOVED: acl: 'public-read',
    metadata: (req, file, cb) => {
      cb(null, { fieldName: file.fieldname });
    },
    key: (req, file, cb) => {
      const ext = file.originalname.split('.').pop();
      cb(null, `driver_docs/${Date.now()}-${file.fieldname}.${ext}`);
    },
  }),
});

module.exports = upload;
