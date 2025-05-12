const { PrismaClient } = require('@prisma/client');
const asyncHandler = require('express-async-handler');
const { S3Client } = require('@aws-sdk/client-s3');
const multer = require('multer');
const multerS3 = require('multer-s3');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

const prisma = new PrismaClient();

// AWS S3 Configuration (v3)
const s3 = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

// Campaign File Upload Configuration
const campaignUpload = multer({
  storage: multerS3({
    s3: s3,
    bucket: process.env.AWS_S3_BUCKET,
    contentType: multerS3.AUTO_CONTENT_TYPE,
    metadata: (req, file, cb) => {
      cb(null, { fieldName: file.fieldname });
    },
    key: (req, file, cb) => {
      const filename = `campaigns/posters/${uuidv4()}_${file.originalname}`;
      cb(null, filename);
    }
  })
});

// Campaign Controllers
exports.createCampaignWithPoster = [
  campaignUpload.single('posterFile'),
  asyncHandler(async (req, res) => {
    const {
      companyId,
      planId,
      title,
      description,
      startDate,
      endDate,
      targetLocation,
      vehicleCount,
      vehicleType,
      posterDesignNeeded,
      posterDesignPrice,
      posterSize,
      totalAmount
    } = req.body;

    // Validate planId is provided
    if (!planId) {
      return res.status(400).json({
        success: false,
        message: "Plan ID is required"
      });
    }

    // Check if the plan exists before creating campaign
    const parsedPlanId = parseInt(planId);
    const plan = await prisma.rechargePlan.findUnique({
      where: { id: parsedPlanId }
    });

    if (!plan) {
      return res.status(404).json({
        success: false,
        message: "Recharge plan not found. Please select a valid plan."
      });
    }

    // Validate companyId is provided
    if (!companyId) {
      return res.status(400).json({
        success: false,
        message: "Company ID is required"
      });
    }

    // Check if the company exists
    const company = await prisma.companyRegistration.findUnique({
      where: { id: companyId }
    });

    if (!company) {
      return res.status(404).json({
        success: false,
        message: "Company not found. Please provide a valid company ID."
      });
    }

    const fileUrl = req.file?.location || null;

    const campaign = await prisma.campaign.create({
      data: {
        companyId,
        planId: parseInt(planId),
        title,
        description,
        startDate: !startDate || startDate === 'null' ? null : new Date(startDate),
        endDate: !endDate || endDate === 'null' ? null : new Date(endDate),
        targetLocation,
        vehicleCount: vehicleCount ? parseInt(vehicleCount) : 1,
        vehicleType,
        posterDesignNeeded: posterDesignNeeded === 'true' || posterDesignNeeded === true,
        posterDesignPrice: posterDesignPrice ? parseFloat(posterDesignPrice) : null,
        posterFile: fileUrl,
        posterSize,
        totalAmount: parseFloat(totalAmount),
        approvalStatus: 'PENDING' // Default status
      }
    });

    res.status(201).json({ success: true, data: campaign });
  })
];

// Rest of the campaign controllers remain unchanged...


// Rest of the campaign controllers remain unchanged
// Get All Campaigns
exports.getAllCampaigns = asyncHandler(async (req, res) => {
  const campaigns = await prisma.campaign.findMany({
    include: {
      company: true,
      plan: true,
      approvedBy: true
    }
  });
  res.json({ success: true, data: campaigns });
});

// Get Campaign by ID
exports.getCampaignById = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const campaign = await prisma.campaign.findUnique({
    where: { id },
    include: {
      company: true,
      plan: true,
      approvedBy: true
    }
  });

  if (!campaign) {
    res.status(404);
    throw new Error('Campaign not found');
  }

  res.json({ success: true, data: campaign });
});

// Update Campaign (only editable fields before approval)
exports.updateCampaign = asyncHandler(async (req, res) => {
  const { id } = req.params;
  
  // Prevent updating certain fields after approval
  const existingCampaign = await prisma.campaign.findUnique({ where: { id } });
  if (existingCampaign.approvalStatus !== 'PENDING') {
    res.status(400);
    throw new Error('Cannot update campaign after approval/rejection');
  }

  const updated = await prisma.campaign.update({
    where: { id },
    data: req.body
  });

  res.json({ success: true, data: updated });
});

// Delete Campaign
exports.deleteCampaign = asyncHandler(async (req, res) => {
  const { id } = req.params;
  await prisma.campaign.delete({ where: { id } });
  res.status(204).send();
});

// Admin Approves Campaign
exports.approveCampaign = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { adminId } = req.body;

  const campaign = await prisma.campaign.update({
    where: { id },
    data: {
      approvalStatus: 'APPROVED',
      approvedById: adminId,
      approvedAt: new Date()
    }
  });

  res.json({ success: true, message: "Campaign approved", data: campaign });
});

// Admin Rejects Campaign
exports.rejectCampaign = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { adminId, reason } = req.body;

  const campaign = await prisma.campaign.update({
    where: { id },
    data: {
      approvalStatus: 'REJECTED',
      rejectionReason: reason,
      approvedById: adminId,
      approvedAt: new Date()
    }
  });

  res.json({ success: true, message: "Campaign rejected", data: campaign });
});