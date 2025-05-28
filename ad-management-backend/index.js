const express = require('express');
const app = express();
const cors = require('cors');
const bodyParser = require('body-parser');
const driverAuth = require('./routes/Driver/DriverAuth/driverAuth'); // Adjust the path as needed
const driverDocumentsUpload = require('./routes/Driver/DriverDocumentsUpload/driverDocumentsUpload'); // Adjust the path as needed
const getPendingDrivers = require('./routes/Admin/DriverDocumnets/driverDocumnetsPendingVerification');
const getPendingCompanies=require('./routes/Admin/CompanyDocumnets/comapnyDocumentsPendingVerification') // Adjust the path as needed
const companyAuth = require('./routes/Company/CompanyAuth/companyAuth'); // Adjust the path as needed
const companyDocumentsUpload = require('./routes/Company/CompanyDocuments/companyDocuments'); // Adjust the path as needed
const adminAuth = require('./routes/Admin/AdminAuth/adminAuth'); // Adjust the path as needed
const manageRechargePlan = require('./routes/Admin/RechargePlan/adminRechargePlan'); // Adjust the path as needed
const CompanyAddCampaign = require('./routes/Company/CompanyLaunchAddCampaign/companyLaunchAddCampaign'); // Adjust the path as needed
const CompaignValidatePayment = require('./routes/Company/CompanyLaunchAddCampaign/campaignValidatePayment_&_Driver'); // Adjust the path as needed
const driverCampaignManagement = require('./routes/Admin/DriverCampaignManagement/driverCampaignManagement'); // Adjust the path as needed
const ComapnyDashboard=require('./routes/Company/CompanyDashboard/campaign-driver-details'); // Adjust the path as needed
const DriverDashboard=require('./routes/Driver/DriverDashboard/comapnyCampaignDetail'); // Adjust the path as needed
const DriverUploadAdvertisementProof = require('./routes/Driver/DriverUploadAdvertisementProof/uploadAdvertisementProofPhoto'); // Adjust the path as needed
const CampaignDriverAdvertisementVerification= require('./routes/Admin/CampaignDriverVerification/driverAdvertisementProofVerification'); // Adjust the path as needed
const CompaignAssignDriversLiveLocation= require('./routes/Company/CompanyViewLiveLocationAllDrivers/companyViewLiveLocationDrivers'); // Adjust the path as needed

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


// Driver All Routes
// Use driver-Authentication Related routes
app.use('/api/driver', driverAuth); // Adjust the path as needed

// Use DriverDocumentsUpload related  routes
app.use('/api/driver-docs', driverDocumentsUpload); // Adjust the path as needed
// Make sure this is in your index.js or wherever you configure routes
app.use('/api/driver', require('./routes/Driver/DriverDocumentsUpload/driverDocumentsUpload'));


app.use('/api/driver-dashboard', DriverDashboard); // Adjust the path as needed

app.use('/api/driver-campaign', DriverUploadAdvertisementProof); 
// Define your other routes and middlewares here

// Add The Driver Live Location To The Data base or Update the live location driver database and redis
app.use('/api/driver-location', require('./routes/Driver/DriverLiveLocation/driverLiveLocation')); // Adjust the path as needed




// Company All Routes
 app.use('/api/company', companyAuth); // Adjust the path as needed

 app.use('/api/company-launch', CompanyAddCampaign) // Adjust the path as needed
 
 app.use('/api/company-validate-payment', CompaignValidatePayment) // Adjust the path as needed
 // Use CompanyDocumentsUpload related routes
 app.use('/api/company-docs', companyDocumentsUpload); // Adjust the path as needed


// CompanyDashobard all company and comapign or Driver Details Route

app.use('/api/company-dashboard',ComapnyDashboard)

// Get all Drivers Live Location for The Assigned Drivers
app.use("/api/company/compaign-assign-drivers",CompaignAssignDriversLiveLocation)




// Admin Verify Company Pending Doucuments For Approval

app.use('/api/admin',getPendingCompanies); // Adjust the path as needed


// Admin Authentication Routes
app.use('/api/admin', adminAuth); // Adjust the path as needed



// Admin Recharge Plan Routes Manage
app.use('/api/admin-manage', manageRechargePlan); // Adjust the path as needed



// Admin Verify Driver Pending Doucuments For Approval

app.use('/api/admin',getPendingDrivers); // Adjust the path as needed



//admin Driver Campaign Management
app.use('/api/admin/driver-campaign-management', driverCampaignManagement ); // Adjust the path as needed


// Admin Campaign Driver Verification
app.use('/api/admin/campaign-driver-verification',CampaignDriverAdvertisementVerification); // Adjust the path as needed

app.use('/api/admin/drivers-locations', require('./routes/Admin/DriversLiveLocation/driversLiveLocation')); // Adjust the path as needed


app.get('/hi', (req, res) => {
  res.send('Welcome to the API!');
})
// Set up server
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Access the server at http://localhost:${PORT}`);
  console.log(`For external access, use your machine's IP address`);
});
