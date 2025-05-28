const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const redis = require('../../../memory/redis');

const DB_UPDATE_INTERVAL_MS = 10 * 1000; // 10 seconds
const lastDbUpdateTimestamps = new Map(); // Tracks last DB update per driver

exports.updateDriverLocation = async (req, res) => {
  const { driverId, lat, lng } = req.body;

  // Better input validation
  if (!driverId) {
    return res.status(400).json({ success: false, error: "Driver ID is required" });
  }
  
  // Validate coordinates
  const latitude = parseFloat(lat);
  const longitude = parseFloat(lng);
  
  if (isNaN(latitude) || isNaN(longitude) || 
      latitude < -90 || latitude > 90 || 
      longitude < -180 || longitude > 180) {
    return res.status(400).json({ 
      success: false, 
      error: "Invalid coordinates. Latitude must be between -90 and 90, Longitude between -180 and 180" 
    });
  }

  const timestamp = new Date().toISOString();
  const locationData = JSON.stringify({ lat: latitude, lng: longitude, timestamp });

  try {
    // ✅ 1. Always update Redis on every request (Flutter sends every 1 second)
    await redis.hset("driver:locations", driverId, locationData)
      .catch(error => {
        console.error(`Redis update failed for driver ${driverId}:`, error);
        // Continue execution to attempt DB update even if Redis fails
      });

    // ✅ 2. Update DB only if 10 seconds have passed since last update
    const now = Date.now();
    const lastUpdate = lastDbUpdateTimestamps.get(driverId) || 0;

    if (now - lastUpdate >= DB_UPDATE_INTERVAL_MS) {
      // Set timestamp before DB operation to prevent concurrent requests from triggering multiple DB updates
      lastDbUpdateTimestamps.set(driverId, now);
      
      try {
        await prisma.driverRegistration.update({
          where: { id: driverId },
          data: {
            currentLocation: { lat: latitude, lng: longitude }, // Store as JSON
            lastLocationUpdate: new Date(), // Add a specific timestamp field
            updatedAt: new Date(),
          },
        });
        console.log(`DB updated for driver ${driverId} at ${new Date().toISOString()}`);
      } catch (dbError) {
        console.error(`DB update failed for driver ${driverId}:`, dbError);
        // If DB update fails, reset the timestamp to allow retrying on next request
        lastDbUpdateTimestamps.set(driverId, lastUpdate);
        return res.status(500).json({ success: false, error: "Database update failed" });
      }
    } else {
      // Calculate time remaining until next DB update
      const timeUntilNextUpdate = DB_UPDATE_INTERVAL_MS - (now - lastUpdate);
      console.log(`Redis only update for driver ${driverId}. Next DB update in ${timeUntilNextUpdate/1000} seconds`);
    }

    return res.json({ 
      success: true, 
      message: "Location updated",
      details: {
        storedInRedis: true,
        storedInDatabase: now - lastUpdate >= DB_UPDATE_INTERVAL_MS,
        nextDatabaseUpdateIn: Math.max(0, DB_UPDATE_INTERVAL_MS - (now - lastUpdate)) / 1000
      }
    });
  } catch (error) {
    console.error("Location update error:", error);
    return res.status(500).json({ success: false, error: "Failed to update location" });
  }
};