const express = require('express');
const router = express.Router();

const { registerAdmin } = require('../../../controllers/Admin/AdminAuthentication/adminRegistration.controller');
const { verifyAdminEmail, resendAdminOtp } = require('../../../controllers/Admin/AdminAuthentication/adminEmailVerification.controller');
const { adminLogin } = require('../../../controllers/Admin/AdminAuthentication/adminLogin.controller');
const { forgotPasswordAdmin } = require('../../../controllers/Admin/AdminAuthentication/adminForgotpassword.controller');
const { resetAdminPassword } = require('../../../controllers/Admin/AdminAuthentication/adminResetPassword.controller');
const { adminVerifyOtp } = require('../../../controllers/Admin/AdminAuthentication/adminLoginOtpVerify.controller');
const { resendLoginAdminOtp } = require('../../../controllers/Admin/AdminAuthentication/adminResendOtpLogin.controller');

// POST /api/admin/register
router.post('/register', registerAdmin);

// POST /api/admin/verify-email
router.post('/verify-email', verifyAdminEmail);

// POST /api/admin/resend-otp
router.post('/resend-otp', resendAdminOtp);

// POST /api/admin/login
router.post('/login', adminLogin);

router.post('/login/resend-otp', resendLoginAdminOtp);

router.post('/login-verify-otp', adminVerifyOtp);

// POST /api/admin/forgot-password
router.post('/forgot-password', forgotPasswordAdmin);

// POST /api/admin/reset-password
router.post('/reset-password', resetAdminPassword);

module.exports = router;
