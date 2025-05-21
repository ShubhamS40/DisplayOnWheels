const express = require('express');
const router = express.Router();
const campaignDriverController = require('../../../controllers/Admin/CampaignDriverVerification/driverAdvertisementProofPhotoVerification.controller');

router.get('/proofs/pending', campaignDriverController.getAllPendingProofs);
router.post('/proofs/approve', campaignDriverController.approveProof);
router.post('/proofs/reject', campaignDriverController.rejectProof);

module.exports = router;
