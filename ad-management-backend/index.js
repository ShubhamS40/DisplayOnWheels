const express = require('express');
const app = express();
const cors = require('cors');
const bodyParser = require('body-parser');
const driverAuth = require('./routes/DriverAuth/driverAuth'); // Adjust the path as needed
const driverDocumentsUpload = require('./routes/DriverDocumentsUpload/driverDocumentsUpload'); // Adjust the path as needed


// Middleware
app.use(cors());
app.use(bodyParser.json()); // for parsing application/json

// Use driver-Authentication Related routes
app.use('/api/driver', driverAuth); // Adjust the path as needed

// Use DriverDocumentsUpload related  routes
app.use('/api/driver-docs', driverDocumentsUpload); // Adjust the path as needed

// Define your other routes and middlewares here

// Set up server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
