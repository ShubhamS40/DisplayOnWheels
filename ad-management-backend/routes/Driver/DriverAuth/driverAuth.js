const express = require('express');
const router = express.Router();
const { registerDriver } = require('../../../controllers/DriverAuthentication/driverRegistration.controller');
const { driverLogin } = require('../../../controllers/DriverAuthentication/driverLogin.controller');
const { forgotPasswordDriver } = require('../../../controllers/DriverAuthentication/driverForgotPassword.controller');
const { resetPassword } = require('../../../controllers/DriverAuthentication/driverResetPassword.controller');
const { verifyEmail,resendOtp } = require('../../../controllers/DriverAuthentication/driverEmailVerification.controller');

// POST /api/driver/register
router.post('/register', registerDriver);

// POST /api/driver/verify-email
router.post('/verify-email', verifyEmail);
// POST /api/driver/resend-otp
router.post('/resend-otp', resendOtp);

// POST /api/driver/login
router.post('/login', driverLogin);



// POST /api/driver/forgot-password
router.post('/forgot-password', forgotPasswordDriver);


// POST /api/driver/reset-password
router.post('/reset-password', resetPassword);

module.exports = router;
