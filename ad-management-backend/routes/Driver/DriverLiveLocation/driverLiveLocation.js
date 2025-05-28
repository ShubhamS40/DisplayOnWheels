  const express = require('express');
const router = express.Router();
const locationController = require('../../../controllers/Driver/DriverLiveLocation/driverLiveLocation.controller');

// DRIVER: Update live location
router.post('/update-location', locationController.updateDriverLocation);




module.exports = router;
