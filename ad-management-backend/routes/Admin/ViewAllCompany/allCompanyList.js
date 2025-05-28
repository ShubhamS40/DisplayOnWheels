const express = require("express");
const { getVerifiedCompanyList } = require("../../../controllers/Admin/ViewAllCompany/companyList.controller");
const router = express.Router();


// GET /admin/company-list
router.get("/company-list", getVerifiedCompanyList);

module.exports = router;
