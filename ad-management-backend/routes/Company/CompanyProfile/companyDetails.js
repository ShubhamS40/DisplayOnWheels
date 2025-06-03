const express = require('express');
const { getCompanyProfile } = require('../../../controllers/Company/CompanyProfile/companyGetAllDetails.controller');
const router = express.Router();



router.get('/company-details/:id', getCompanyProfile )// getDriverProfile);
// On the basis of this api we will get the driver details

module.exports = router;