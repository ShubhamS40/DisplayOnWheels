const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function getAllPlans(req, res) {
  try {
    const plans = await prisma.rechargePlan.findMany({
      include: { features: true }
    });
    res.json(plans);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function getPlanById(req, res) {
  const { id } = req.params;
  try {
    const plan = await prisma.rechargePlan.findUnique({
      where: { id: parseInt(id) },
      include: { features: true }
    });
    if (!plan) return res.status(404).json({ error: 'Plan not found' });
    res.json(plan);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function createPlan(req, res) {
  const {
    title,
    subtitle,
    note,
    price,
    durationDays,
    features,
    isRecommended,
    isActive,
    maxVehicles
  } = req.body;

  try {
    const newPlan = await prisma.rechargePlan.create({
      data: {
        title,
        subtitle,
        note,
        price,
        durationDays,
        isRecommended,
        isActive,
        maxVehicles,
        features: {
          create: features.map(feature => ({
            feature: feature
          }))
        }
      },
      include: { features: true }
    });

    res.status(201).json(newPlan);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
}

async function updatePlan(req, res) {
  const {
    id
  } = req.params;
  const {
    title,
    subtitle,
    note,
    price,
    durationDays,
    features,
    isRecommended,
    isActive,
    maxVehicles
  } = req.body;

  try {
    // First, delete existing features
    await prisma.rechargePlanFeature.deleteMany({
      where: { rechargePlanId: parseInt(id) }
    });

    // Then update the plan and recreate features
    const updatedPlan = await prisma.rechargePlan.update({
      where: { id: parseInt(id) },
      data: {
        title,
        subtitle,
        note,
        price,
        durationDays,
        isRecommended,
        isActive,
        maxVehicles,
        features: {
          create: features.map(feature => ({
            feature: feature
          }))
        }
      },
      include: { features: true }
    });

    res.json(updatedPlan);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
}

async function togglePlanActive(req, res) {
  const { id } = req.params;
  const { isActive } = req.body;
  try {
    const updatedPlan = await prisma.rechargePlan.update({
      where: { id: parseInt(id) },
      data: { isActive }
    });
    res.json(updatedPlan);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function deletePlan(req, res) {
  const { id } = req.params;
  try {
    // First, delete related features
    await prisma.rechargePlanFeature.deleteMany({
      where: { rechargePlanId: parseInt(id) }
    });

    // Then delete the plan itself
    await prisma.rechargePlan.delete({
      where: { id: parseInt(id) }
    });

    res.json({ message: 'Plan and related features deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function seedDefaultPlans(req, res) {
  try {
    // Check if any plans exist
    const existingPlans = await prisma.rechargePlan.count();
    
    if (existingPlans > 0) {
      return res.json({
        message: 'Plans already exist',
        count: existingPlans
      });
    }

    // Create default plans if none exist
    const defaultPlans = [
      {
        title: 'Basic Plan',
        subtitle: 'For small campaigns',
        note: 'Perfect for local advertising',
        price: 2000,
        durationDays: 7,
        isRecommended: false,
        isActive: true,
        maxVehicles: 5,
        features: ['Basic analytics', 'Local area coverage', 'Email support']
      },
      {
        title: 'Standard Plan',
        subtitle: 'Our most popular option',
        note: 'Ideal for medium businesses',
        price: 5000,
        durationDays: 15,
        isRecommended: true,
        isActive: true,
        maxVehicles: 10,
        features: ['Advanced analytics', 'City-wide coverage', 'Priority support', 'Campaign optimization']
      },
      {
        title: 'Premium Plan',
        subtitle: 'Maximum exposure',
        note: 'Best for established brands',
        price: 10000,
        durationDays: 30,
        isRecommended: false,
        isActive: true,
        maxVehicles: 20,
        features: ['Real-time analytics', 'Multi-city coverage', 'Dedicated account manager', 'Premium vehicle selection', 'Performance guarantees']
      }
    ];

    // Use a transaction to ensure all plans are created successfully
    const createdPlans = await prisma.$transaction(
      defaultPlans.map(plan => {
        const { features, ...planData } = plan;
        return prisma.rechargePlan.create({
          data: {
            ...planData,
            features: {
              create: features.map(feature => ({
                feature: feature
              }))
            }
          },
          include: { features: true }
        });
      })
    );

    res.status(201).json({
      message: 'Default plans created successfully',
      plans: createdPlans
    });
  } catch (error) {
    console.error('Error seeding default plans:', error);
    res.status(500).json({
      error: error.message,
      message: 'Failed to seed default plans'
    });
  }
}

module.exports = {
  getAllPlans,
  getPlanById,
  createPlan,
  updatePlan,
  togglePlanActive,
  deletePlan,
  seedDefaultPlans
};
