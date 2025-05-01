const express = require('express');
const router = express.Router();

const { getPendingCompanies } = require('../../../controllers/Admin/CompanyDocumnetsVerification/companyPendingDocumnets');
const { viewCompanyDocuments } = require('../../../controllers/Admin/CompanyDocumnetsVerification/viewCompanyDocuments.controller');
const { verifyCompanyDocuments } = require('../../../controllers/Admin/CompanyDocumnetsVerification/verifyCompanyDocuments.controller');

// Route: GET /admin/pending-company-documents
router.get('/pending-company-documents', getPendingCompanies);

// Route: GET /admin/company-documents/:companyId
router.get('/company-documents/:companyId', viewCompanyDocuments);

// Route: PUT /admin/company-documents/:companyId/verify
router.put('/company-documents/:companyId/verify', verifyCompanyDocuments);

module.exports = router;
