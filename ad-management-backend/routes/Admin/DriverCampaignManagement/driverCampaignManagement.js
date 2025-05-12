const {getVerifiedDrivers,  getDriversWithoutCampaign}=require("../../../controllers/Admin/DriverDocumnetsVerification/getVerifiedDrivers.controller")
const express = require('express');
const router = express.Router();



router.get('/verified-drivers', getVerifiedDrivers);


// Available Drivers for Campaign Who Have Not Yet Assigned
router.get('/available-drivers', getDriversWithoutCampaign);


module.exports = router;