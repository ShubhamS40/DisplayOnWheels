const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const redis = require('../../../memory/redis');

const DB_UPDATE_INTERVAL_MS = 10 * 1000;
const lastDbUpdateTimestamps = new Map();

exports.getAdminAllDriverLocations = async (req, res) => {
  try {
    const redisData = await redis.hgetall("driver:locations");

    if (!redisData || Object.keys(redisData).length === 0) {
      return res.json({
        success: true,
        drivers: [],
        message: "No driver locations available"
      });
    }

    const driverIds = Object.keys(redisData);

    const driversData = await prisma.driverRegistration.findMany({
      where: {
        id: { in: driverIds }
      },
      select: {
        id: true,
        fullName: true,
        contactNumber: true,
        email: true,
        vehicleNumber: true,
        vehicleType: true,
        isAvailable: true,
        isEmailVerified: true,
        createdAt: true
      }
    });

    const driversMap = {};
    driversData.forEach(driver => {
      driversMap[driver.id] = driver;
    });

    const enhancedDrivers = Object.entries(redisData).map(([driverId, locStr]) => {
      try {
        const locationData = JSON.parse(locStr);
        const driverInfo = driversMap[driverId] || { id: driverId };

        return {
          driverId,
          name: driverInfo.fullName || "Unknown Driver",
          phone: driverInfo.contactNumber,
          email: driverInfo.email,
          vehicleNumber: driverInfo.vehicleNumber,
          vehicleType: driverInfo.vehicleType,
          profileImage: driverInfo.profileImage,
          isActive: driverInfo.isAvailable || false,
          isApproved: driverInfo.isEmailVerified || false,
          lat: parseFloat(locationData.lat),
          lng: parseFloat(locationData.lng),
          timestamp: locationData.timestamp,
          lastUpdateAgo: getTimeDifference(locationData.timestamp)
        };
      } catch (error) {
        console.error(`Error parsing location data for driver ${driverId}:`, error);
        return null;
      }
    }).filter(item => item !== null);

    const responseMetadata = {
      totalDrivers: enhancedDrivers.length,
      activeDrivers: enhancedDrivers.filter(d => d.isActive).length,
      timestamp: new Date().toISOString()
    };

    res.json({
      success: true,
      drivers: enhancedDrivers,
      metadata: responseMetadata
    });
  } catch (error) {
    console.error("Admin fetch error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to fetch driver locations",
      message: error.message
    });
  }
};

function getTimeDifference(timestamp) {
  if (!timestamp) return "unknown";

  const then = new Date(timestamp);
  const now = new Date();
  const diffMs = now - then;

  if (diffMs < 60000) {
    return "Just now";
  } else if (diffMs < 3600000) {
    const minutes = Math.floor(diffMs / 60000);
    return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
  } else if (diffMs < 86400000) {
    const hours = Math.floor(diffMs / 3600000);
    return `${hours} hour${hours > 1 ? 's' : ''} ago`;
  } else {
    const days = Math.floor(diffMs / 86400000);
    return `${days} day${days > 1 ? 's' : ''} ago`;
  }
}
