const express = require('express');
const router = express.Router();
const campaignController = require('../../../controllers/Company/CompanyLaunchAddCampain/companyLaunchAddCampaign.controller');

// Launch campaign
router.post('/create-add-campaign', campaignController.createCampaignWithPoster);

// List all campaigns
router.get('/', campaignController.getAllCampaigns);

// Get specific campaign
router.get('/:id', campaignController.getCampaignById);

// Update campaign (e.g. before approval)
router.put('/:id', campaignController.updateCampaign);

// Delete campaign
router.delete('/:id', campaignController.deleteCampaign);

// Admin Approve
router.post('/:id/approve', campaignController.approveCampaign);

// Admin Reject
router.post('/:id/reject', campaignController.rejectCampaign);

module.exports = router;
