const express = require('express');
const { getDriverDetailsById } = require('../../../controllers/Admin/ViewAllDrivers/individualDriversBriefDetails.controller');

const router = express.Router();

router.get('/driver/:id',getDriverDetailsById );

module.exports = router;
