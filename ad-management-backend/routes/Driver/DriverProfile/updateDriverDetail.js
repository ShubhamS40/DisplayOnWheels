

// put api to edit the driver details


const express = require('express');

const { updateDriverDetails } = require('../../../controllers/Driver/DriverProfile/updateDriverDetails.controller');


const router = express.Router();


router.put('/update-driver-details/:id', updateDriverDetails )// updateDriverDetails); // This should point to the controller function that handles the update logic
// On the basis of this API, we will update the driver details