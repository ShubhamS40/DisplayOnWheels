// routes/driverRoutes.js

const express = require('express');
const { getVerifiedDrivers } = require('../../../controllers/Admin/ViewAllDrivers/driversList.controller');
const router = express.Router();


router.get('/verified-drivers', getVerifiedDrivers);

module.exports = router;
