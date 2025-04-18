const express = require('express');
const app = express();
const cors = require('cors');
const bodyParser = require('body-parser');
const driverRoutes = require('./routes/DriverAuth/driverAuth'); // Adjust the path as needed

// Middleware
app.use(cors());
app.use(bodyParser.json()); // for parsing application/json

// Use driver-related routes
app.use('/api/driver', driverRoutes);

// Define your other routes and middlewares here

// Set up server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
