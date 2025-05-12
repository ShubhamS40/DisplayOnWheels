import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_dashboard/company_dashboard_screen.dart';

class PaymentConfirmationDialog extends StatelessWidget {
  final Map<String, dynamic> campaignDetails;
  final bool isDarkMode;
  final Color orangeColor;
  final int totalAmount;

  const PaymentConfirmationDialog({
    Key? key,
    required this.campaignDetails,
    required this.isDarkMode,
    required this.orangeColor,
    required this.totalAmount,
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
          Text(
            'This will initiate the payment process. Once payment is complete, your campaign will be sent for admin verification.',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 12,
              fontStyle: FontStyle.italic,
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
            
            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => _PaymentLoadingDialog(
                isDarkMode: isDarkMode,
                orangeColor: orangeColor,
                totalAmount: totalAmount,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PaymentLoadingDialog extends StatefulWidget {
  final bool isDarkMode;
  final Color orangeColor;
  final int totalAmount;

  const _PaymentLoadingDialog({
    Key? key,
    required this.isDarkMode,
    required this.orangeColor,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<_PaymentLoadingDialog> createState() => _PaymentLoadingDialogState();
}

class _PaymentLoadingDialogState extends State<_PaymentLoadingDialog> {
  @override
  void initState() {
    super.initState();
    // Simulate API call delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);
        
        // Show success message and navigate back to dashboard
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
            title: Text(
              'Payment Successful!',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: widget.orangeColor,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Payment of Rs. ${widget.totalAmount}/- successful.',
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your campaign has been successfully launched and is pending admin verification.',
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.orangeColor,
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: widget.orangeColor),
          const SizedBox(height: 16),
          Text(
            'Processing payment...',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
