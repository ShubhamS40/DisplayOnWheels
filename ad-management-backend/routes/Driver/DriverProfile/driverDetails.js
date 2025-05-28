const express = require('express');
const { getDriverProfile } = require('../../../controllers/Driver/DriverProfile/driverGetAllDeatils.controller');
const router = express.Router();



router.get('/driver-details/:id', getDriverProfile )// getDriverProfile);
// On the basis of this api we will get the driver details

module.exports = router;