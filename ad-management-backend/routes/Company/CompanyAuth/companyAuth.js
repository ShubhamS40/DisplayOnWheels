const express = require('express');
const router = express.Router();

const { driverLogin } = require('../../../controllers/DriverAuthentication/driverLogin.controller');
const { forgotPasswordDriver } = require('../../../controllers/DriverAuthentication/driverForgotPassword.controller');
const { resetPassword } = require('../../../controllers/DriverAuthentication/driverResetPassword.controller');
const { verifyEmail,resendOtp } = require('../../../controllers/DriverAuthentication/driverEmailVerification.controller');
const { registerCompany } = require('../../../controllers/Company/CompanyAuthentication/companyRegistration.controller');
const { verifyCompanyEmail, resendCompanyOtp } = require('../../../controllers/Company/CompanyAuthentication/companyEmailVerification.controller');
const { companyLogin } = require('../../../controllers/Company/CompanyAuthentication/companyLogin.controller');
const { forgotPasswordCompany } = require('../../../controllers/Company/CompanyAuthentication/companyForgotPassword.controller');
const { resetCompanyPassword } = require('../../../controllers/Company/CompanyAuthentication/companyResetPassword.controller');

// POST /api/company/register
router.post('/register', registerCompany);


// POST /api/company/verify-email
router.post('/verify-email', verifyCompanyEmail);

// POST /api/company/resend-otp
router.post('/resend-otp', resendCompanyOtp);


// POST /api/company/login
router.post('/login', companyLogin);


// POST /api/company/forgot-password
router.post('/forgot-password', forgotPasswordCompany);


// POST /api/company/reset-password
router.post('/reset-password', resetCompanyPassword);




module.exports = router;