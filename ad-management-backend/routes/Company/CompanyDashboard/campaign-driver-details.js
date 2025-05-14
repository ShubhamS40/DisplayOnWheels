// routes/campaignRoutes.js
const express = require('express');
const router = express.Router();
const campaignController = require('../../../controllers/Company/ComapnyDashboard/campaign-driver-details.controllers');

// const { authenticateCompany } = require('../middleware/auth'); // Assuming you have auth middleware






router.get("/",(req,res)=>{
    res.send("Welcome to the Company Dashboard API");
})

// Get all campaigns for a company with status filter

router.get('/company/:companyId/campaigns',  campaignController.getCompanyCampaigns);

// Get detailed campaign info with allocated drivers
router.get('/campaigns/:campaignId', campaignController.getCompanyCampaignDetails);

// Get driver details for a specific campaign
router.get('/campaigns/:campaignId/drivers/:driverId',  campaignController.getDriverDetails);

module.exports = router;