const express = require('express');
const app = express();
const cors = require('cors');
const bodyParser = require('body-parser');
const driverAuth = require('./routes/Driver/DriverAuth/driverAuth'); // Adjust the path as needed
const driverDocumentsUpload = require('./routes/Driver/DriverDocumentsUpload/driverDocumentsUpload'); // Adjust the path as needed
const getPendingDrivers = require('./routes/Admin/DriverDocumnets/driverDocumnetsPendingVerification'); // Adjust the path as needed


// Middleware
// Enable CORS for all routes and origins (for development)
app.use(cors({
  origin: '*',  // Allow all origins
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Increase payload limit for file uploads
app.use(bodyParser.json({ limit: '50mb' })); 
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true })); // for parsing application/x-www-form-urlencoded

// Use driver-Authentication Related routes
app.use('/api/driver', driverAuth); // Adjust the path as needed

// Use DriverDocumentsUpload related  routes
app.use('/api/driver-docs', driverDocumentsUpload); // Adjust the path as needed
// Make sure this is in your index.js or wherever you configure routes
app.use('/api/driver', require('./routes/Driver/DriverDocumentsUpload/driverDocumentsUpload'));

// Define your other routes and middlewares here



// Admin Verify Driver Pending Doucuments For Approval

app.use('/api/admin',getPendingDrivers); // Adjust the path as needed

// Set up server
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Access the server at http://localhost:${PORT}`);
  console.log(`For external access, use your machine's IP address`);
});
