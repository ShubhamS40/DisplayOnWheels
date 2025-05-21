// routes/admin.js

router.get('/all-drivers-locations', async (req, res) => {
  try {
    const drivers = await prisma.driverRegistration.findMany({
      select: {
        id: true,
        fullName: true,
        currentLocation: true
      }
    });

    res.json({ success: true, drivers });
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch drivers' locations" });
  }
});
