// routes/company.js

router.get('/:companyId/drivers-locations', async (req, res) => {
  const { companyId } = req.params;

  try {
    const drivers = await prisma.campaignDriver.findMany({
      where: {
        campaign: {
          companyId: companyId
        },
        status: { not: "COMPLETED" }
      },
      select: {
        driver: {
          select: {
            id: true,
            fullName: true,
            currentLocation: true
          }
        },
        campaignId: true
      }
    });

    res.json({ success: true, drivers });
  } catch (error) {
    res.status(500).json({ error: "Unable to fetch driver locations" });
  }
});