const express = require('express');
const router = express.Router();

const { getPendingDrivers } = require('../../../controllers/Admin/DriverDocumnetsVerification/driverPendingDocumnets');
const { verifyDriverDocuments } = require('../../../controllers/Admin/DriverDocumnetsVerification/verifyDriverDocuments.controller');
const { viewDriverDocuments } = require('../../../controllers/Admin/DriverDocumnetsVerification/viewDriverDocuments.controller');

// Route: GET /admin/pending-drivers-documents for verification
router.get('/pending-drivers-documents', getPendingDrivers);


router.get('/driver-documents/:driverId', viewDriverDocuments);
router.put('/driver-documents/:driverId/verify', verifyDriverDocuments);

module.exports = router;
