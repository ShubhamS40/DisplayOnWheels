
const express = require('express');
const router = express.Router();
const locationController = require('../../../controllers/Admin/DriverLocations/driversLocations.controller');


// // ADMIN: View all drivers' live locations
router.get('/all-drivers-locations', locationController.getAdminAllDriverLocations);

module.exports = router;
