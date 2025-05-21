// routes/driver.js

const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// POST /api/driver/update-location
router.post('/update-location', async (req, res) => {
  const { driverId, lat, lng } = req.body;

  if (!driverId || !lat || !lng) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    await prisma.driverRegistration.update({
      where: { id: driverId },
      data: {
        currentLocation: { lat, lng },
        updatedAt: new Date()
      }
    });

    res.json({ success: true, message: "Location updated" });
  } catch (error) {
    res.status(500).json({ error: "Failed to update location" });
  }
});

module.exports = router;