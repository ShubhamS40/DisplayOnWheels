const express = require('express');
const router = express.Router();
const {
  createPlan,
  deletePlan,
  getAllPlans,
  getPlanById,
  togglePlanActive,
  updatePlan,
  seedDefaultPlans
} = require('../../../controllers/Admin/CompanyRechargePlan/adminManageCompanyRechargePlan.controller');

// Get all plans
router.get('/recharge', getAllPlans);

// Get plan by ID
router.get('/recharge/:id', getPlanById);

// Create new plan
router.post('/create-recharge-plan', createPlan);

// Update plan
router.put('/update-recharge-plan/:id', updatePlan);

// Toggle plan active/inactive
router.patch('/is-recharge-plan-active/:id/active', togglePlanActive);

// Delete plan
router.delete('/delete-recharge-plan/:id', deletePlan);

// Seed default plans if none exist
router.post('/seed-default-plans', seedDefaultPlans);

module.exports = router;
