const express = require('express');
const router = express.Router();

const {
  assignDriversToCampaign,
  getCampaignWithDrivers,
  validateAndRecordPayment
} = require('../../../controllers/Company/CompanyLaunchAddCampain/compaignPayment_Allocate_Driver.controller');

// Get campaign with driver and payment details
router.get('/campaign/:id', getCampaignWithDrivers);

// Admin assigns drivers to a campaign
router.post('/campaign/:id/assign-drivers', assignDriversToCampaign);

// Validate and record payment
router.post('/payment/record', validateAndRecordPayment);

module.exports = router;
