  const express = require('express');
const router = express.Router();
const locationController = require('../../../controllers/Company/CompanyViewDriverLocation/companyViewDriverLocation.controller');



// COMPANY: View only own drivers' live locations
router.get('/:companyId/drivers-locations', locationController.getCompanyDriverLocations);


module.exports = router;