const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const redis = require('../../../memory/redis');

// Company driver locations API - shows only drivers assigned to their campaigns
exports.getCompanyDriverLocations = async (req, res) => {
  const { companyId } = req.params;

  try {
    // Find all active campaign drivers for this company's campaigns
    const campaignDrivers = await prisma.campaignDriver.findMany({
      where: {
        campaign: {
          companyId: companyId, // Ensure we only get this company's campaigns
        },
        status: {
          in: ['ASSIGNED', 'IN_PROGRESS'] // Only get active drivers
        }
      },
      select: {
        id: true,
        driverId: true,
        campaignId: true,
        status: true,
        driver: {
          select: {
            fullName: true,
            contactNumber: true,
            email: true,
            vehicleNumber: true,
            vehicleType: true,
            isAvailable: true,
          }
        },
        campaign: {
          select: {
            title: true
          }
        }
      }
    });

    if (campaignDrivers.length === 0) {
      return res.json({ 
        success: true, 
        drivers: [],
        metadata: {
          totalDrivers: 0,
          activeDrivers: 0,
          timestamp: new Date().toISOString()
        }
      });
    }

    // Get location data from Redis for these drivers
    const redisData = await redis.hmget(
      "driver:locations",
      ...campaignDrivers.map(cd => cd.driverId)
    );

    // Combine driver information with location data
    const locations = campaignDrivers.map((cd, i) => {
      const locationData = redisData[i] ? JSON.parse(redisData[i]) : null;
      
      // Only include drivers with valid location data
      if (!locationData || !locationData.lat || !locationData.lng) {
        return null;
      }
      
      return {
        driverId: cd.driverId,
        campaignDriverId: cd.id,
        campaignId: cd.campaignId,
        campaignTitle: cd.campaign.title,
        name: cd.driver.fullName,
        phone: cd.driver.contactNumber,
        email: cd.driver.email,
        vehicleNumber: cd.driver.vehicleNumber,
        vehicleType: cd.driver.vehicleType,
        isActive: cd.status === 'IN_PROGRESS',
        isAssigned: true,
        latitude: locationData.lat,
        longitude: locationData.lng,
        timestamp: locationData.timestamp || new Date().toISOString(),
        lastUpdateAgo: locationData.timestamp 
          ? getTimeAgo(new Date(locationData.timestamp)) 
          : 'Just now'
      };
    }).filter(Boolean); // Remove null entries (drivers without location)

    // Calculate metadata
    const activeDrivers = locations.filter(d => d.isActive).length;

    res.json({
      success: true,
      drivers: locations,
      metadata: {
        totalDrivers: locations.length,
        activeDrivers: activeDrivers,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error("Company driver location fetch error:", error);
    res.status(500).json({ 
      success: false, 
      error: "Failed to fetch driver locations" 
    });
  }
};

// Helper function to format time ago
function getTimeAgo(timestamp) {
  const now = new Date();
  const diffMs = now - timestamp;
  const diffSec = Math.floor(diffMs / 1000);
  
  if (diffSec < 60) return `${diffSec} seconds ago`;
  if (diffSec < 3600) return `${Math.floor(diffSec / 60)} minutes ago`;
  if (diffSec < 86400) return `${Math.floor(diffSec / 3600)} hours ago`;
  return `${Math.floor(diffSec / 86400)} days ago`;
}