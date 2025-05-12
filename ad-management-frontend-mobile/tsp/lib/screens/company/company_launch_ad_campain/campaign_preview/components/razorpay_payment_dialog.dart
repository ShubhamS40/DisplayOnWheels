import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tsp/screens/company/company_dashboard/company_dashboard_screen.dart';
import 'package:tsp/services/payment/payment_manager.dart';
import 'package:tsp/utils/theme_constants.dart';
import 'package:tsp/services/campaign/campaign_service.dart';

class RazorPaymentDialog extends StatelessWidget {
  final Map<String, dynamic> campaignDetails;
  final bool isDarkMode;
  final Color orangeColor;
  final int totalAmount;
  
  // User details - in a real app, these would come from user profile
  final String userEmail;
  final String userPhone;
  final String userName;

  const RazorPaymentDialog({
    Key? key,
    required this.campaignDetails,
    required this.isDarkMode,
    required this.orangeColor,
    required this.totalAmount,
    this.userEmail = 'user@example.com', // Default value for demo
    this.userPhone = '9876543210',       // Default value for demo
    this.userName = 'Test User',         // Default value for demo
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      title: Text(
        'Confirm Campaign Launch',
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to launch this campaign?',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Plan: ${campaignDetails['selectedPlan']}',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Duration: ${campaignDetails['planDuration'] ?? "Not specified"}',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vehicles: ${campaignDetails['carCount']}',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          if (campaignDetails['needsPosterDesign'] == true) ...[
            const SizedBox(height: 4),
            Text(
              'Custom Poster Design: Yes',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Design Size: ${campaignDetails['posterSize'] ?? 'A3'}',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
          const Divider(),
          Text(
            'Total Payment: Rs. $totalAmount/-',
            style: TextStyle(
              color: orangeColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black12 : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: orangeColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/razorpay_logo.png',
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.payment,
                      color: orangeColor,
                      size: 24,
                    );
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment will be processed securely via RazorPay',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: orangeColor,
          ),
          child: const Text('Pay Now'),
          onPressed: () {
            // Close dialog
            Navigator.pop(context);
            
            // Create and initialize payment manager
            _initializePayment(context);
          },
        ),
      ],
    );
  }
  
  void _initializePayment(BuildContext context) {
    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PaymentProcessingDialog(
        isDarkMode: isDarkMode,
        orangeColor: orangeColor,
        message: 'Processing Payment...',
      ),
    );
    
    // Create payment manager with callbacks
    final paymentManager = PaymentManager(
      onPaymentComplete: (String paymentId) {
        // Submit campaign data to API
        _submitCampaignData(context, paymentId);
      },
      onPaymentError: (error) {
        // Close processing dialog
        Navigator.pop(context);
        // Show error message
        _showErrorDialog(context, error);
      },
    );
    
    // Start the payment directly (RazorPay SDK will show its own UI)
    paymentManager.startCampaignPayment(
      campaignName: campaignDetails['adTitle'] ?? 'Ad Campaign',
      totalAmount: totalAmount,
      customerName: userName,
      customerEmail: userEmail,
      customerPhone: userPhone,
    );
    
    // Close our dialog - RazorPay will show its own UI
    Navigator.pop(context);
  }
  
  // Submit campaign data to API after successful payment
  Future<void> _submitCampaignData(BuildContext context, String paymentId) async {
    // Update processing dialog message
    Navigator.pop(context); // Remove previous dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PaymentProcessingDialog(
        isDarkMode: isDarkMode,
        orangeColor: orangeColor,
        message: 'Submitting campaign data...',
      ),
    );
    
    // Submit campaign data using campaign service
    final campaignService = CampaignService();
    final success = await campaignService.launchCampaign(
      campaignData: campaignDetails,
      paymentId: paymentId,
    );
    
    // Close processing dialog
    Navigator.pop(context);
    
    if (success) {
      // Show success message and navigate to dashboard
      _showSuccessAndNavigate(context);
    } else {
      // Show error with option to retry
      _showErrorDialog(
        context, 
        'Payment was successful but there was an error submitting your campaign. Please contact support with your payment ID: $paymentId',
      );
    }
  }
  
  void _showSuccessAndNavigate(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Payment Successful!',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: orangeColor,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Payment of Rs. $totalAmount/- successful.',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your campaign has been successfully launched and is pending admin verification.',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeColor,
            ),
            child: const Text('Back to Dashboard'),
            onPressed: () {
              // Navigate back to dashboard
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const CompanyDashboardScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Payment Failed',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeColor,
            ),
            child: const Text('Try Again'),
            onPressed: () {
              // Close error dialog
              Navigator.pop(context);
              
              // Reopen payment dialog
              showDialog(
                context: context,
                builder: (context) => RazorPaymentDialog(
                  campaignDetails: campaignDetails,
                  isDarkMode: isDarkMode,
                  orangeColor: orangeColor,
                  totalAmount: totalAmount,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Dialog displayed during payment processing
class _PaymentProcessingDialog extends StatelessWidget {
  final bool isDarkMode;
  final Color orangeColor;
  final String message;

  const _PaymentProcessingDialog({
    Key? key,
    required this.isDarkMode,
    required this.orangeColor,
    this.message = 'Processing Payment...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(orangeColor),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please do not close this window',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
