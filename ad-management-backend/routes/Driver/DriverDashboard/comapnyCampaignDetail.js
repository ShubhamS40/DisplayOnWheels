const express = require('express');
const router = express.Router();
const { getDriverCampaigns } = require('../../../controllers/Driver/DriverDashboard/companyCampaignDetail.controller');

// On the basis on this api we will get the driver campaign details and company and plan details 
router.get('/campaigns-details/:driverId', getDriverCampaigns)


module.exports = router;