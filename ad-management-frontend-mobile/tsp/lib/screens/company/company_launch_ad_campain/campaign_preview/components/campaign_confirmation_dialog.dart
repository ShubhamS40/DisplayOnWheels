import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsp/screens/company/company_dashboard/company_dashboard_screen.dart';
import 'package:tsp/services/campaign/campaign_service.dart';
import 'package:http_parser/http_parser.dart';

// Global navigator key for safer navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class CampaignConfirmationDialog extends ConsumerWidget {
  final Map<String, dynamic> campaignDetails;
  final bool isDarkMode;
  final Color orangeColor;
  final int totalAmount;

  const CampaignConfirmationDialog({
    Key? key,
    required this.campaignDetails,
    required this.isDarkMode,
    required this.orangeColor,
    required this.totalAmount,
  }) : super(key: key);

  // Helper method to build section titles
  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label: ',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get company ID asynchronously
  Future<String?> _getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('companyId');
  }

  // Helper method to extract plan ID from plan name
  int _extractPlanId(String? planName) {
    if (planName == null) return 1;
    switch (planName.toLowerCase()) {
      case 'basic':
        return 1;
      case 'standard':
        return 2;
      case 'premium':
        return 3;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      title: Text(
        'Confirm Campaign Launch',
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campaign Preview Details',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Campaign Basic Details
            _buildSectionTitle('Campaign Information', isDarkMode),
            _buildDetailRow('Campaign Title',
                campaignDetails['adTitle'] ?? 'Not specified', isDarkMode),
            _buildDetailRow('Plan',
                campaignDetails['selectedPlan'] ?? 'Not specified', isDarkMode),
            _buildDetailRow(
                'Plan ID',
                _extractPlanId(campaignDetails['selectedPlan']).toString(),
                isDarkMode),
            _buildDetailRow('Duration',
                campaignDetails['planDuration'] ?? 'Not specified', isDarkMode),

            // Vehicle Details
            _buildSectionTitle('Vehicle Details', isDarkMode),
            _buildDetailRow('Vehicle Type',
                campaignDetails['vehicleType'] ?? 'Not specified', isDarkMode),
            _buildDetailRow('Number of Vehicles',
                '${campaignDetails['carCount'] ?? 0}', isDarkMode),
            _buildDetailRow(
                'Target Location',
                campaignDetails['targetLocation'] ?? 'Not specified',
                isDarkMode),

            // Poster Details
            _buildSectionTitle('Poster Details', isDarkMode),
            if (campaignDetails['needsPosterDesign'] == true)
              Column(
                children: [
                  _buildDetailRow('Custom Poster Design', 'Yes', isDarkMode),
                  _buildDetailRow('Design Size',
                      campaignDetails['posterSize'] ?? 'A3', isDarkMode),
                  if (campaignDetails['designNotes'] != null)
                    _buildDetailRow('Design Notes',
                        campaignDetails['designNotes'], isDarkMode),
                ],
              )
            else
              Column(
                children: [
                  _buildDetailRow(
                      'Using Custom Poster',
                      campaignDetails['posterFile'] != null ||
                              campaignDetails['posterBytes'] != null
                          ? 'Yes'
                          : 'No',
                      isDarkMode),
                  _buildDetailRow('Poster Size',
                      campaignDetails['posterSize'] ?? 'A3', isDarkMode),
                ],
              ),

            // Company and Payment Details
            _buildSectionTitle('Company and Payment Details', isDarkMode),
            FutureBuilder<String?>(
              future: _getCompanyId(),
              builder: (context, snapshot) {
                return _buildDetailRow(
                    'Company ID', snapshot.data ?? 'Loading...', isDarkMode);
              },
            ),
            _buildDetailRow('Plan Price',
                'Rs. ${campaignDetails['planPrice'] ?? 0}/-', isDarkMode),
            if (campaignDetails['needsPosterDesign'] == true)
              _buildDetailRow(
                  'Poster Design Price',
                  'Rs. ${campaignDetails['posterDesignPrice'] ?? 0}/-',
                  isDarkMode),

            const Divider(thickness: 1),
            Text(
              'Total Amount: Rs. $totalAmount/-',
              style: TextStyle(
                color: orangeColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
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
          child: const Text('Confirm Campaign'),
          onPressed: () {
            Navigator.pop(context);
            _submitCampaign(context, ref);
          },
        ),
      ],
    );
  }

  Future<void> _submitCampaign(BuildContext context, WidgetRef ref) async {
    // Store context in a local variable to maintain a reference to the mounted state
    final BuildContext dialogContext = context;

    // Create a NavigatorState variable to safely access Navigator later
    final NavigatorState navigator = Navigator.of(dialogContext);

    // Create a GlobalKey to access the dialog state
    final GlobalKey<_ProcessingDialogState> dialogKey =
        GlobalKey<_ProcessingDialogState>();

    // Keep track of whether dialog is showing
    bool isDialogShowing = true;

    // Show the processing dialog with the key
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (BuildContext context) => _ProcessingDialog(
        key: dialogKey,
        isDarkMode: isDarkMode,
        orangeColor: orangeColor,
        message: 'Creating campaign...',
      ),
    );

    // Create the campaign service
    final campaignService = CampaignService();

    // Create a function to safely close dialog
    void closeDialogSafely() {
      if (isDialogShowing && navigator.mounted) {
        isDialogShowing = false;
        navigator.pop();
      }
    }

    try {
      debugPrint('Campaign creation started');

      // Only for progress simulation
      await Future.delayed(const Duration(milliseconds: 500));

      if (!navigator.mounted) return;

      if (dialogKey.currentState != null && dialogKey.currentState!.mounted) {
        dialogKey.currentState!.updateProgress(0.3);
        dialogKey.currentState!.updateMessage('Uploading campaign details...');
      }

      // Log the campaign data being sent
      debugPrint('Sending campaign data: ${jsonEncode(campaignDetails)}');

      // Add progress update callback to track upload progress
      final result = await campaignService.launchCampaign(
        campaignData: campaignDetails,
        // Removed ref parameter to prevent "Cannot use ref after widget was disposed" error
        onProgressUpdate: (progress) {
          // Use a safer way to update progress that doesn't depend on BuildContext
          if (dialogKey.currentState != null &&
              dialogKey.currentState!.mounted) {
            dialogKey.currentState!.updateProgress(progress);
            if (progress > 0.9) {
              dialogKey.currentState!
                  .updateMessage('Processing campaign data...');
            }
          }
          debugPrint(
              'Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
        },
      );

      debugPrint('Campaign API call completed with result: $result');

      // Close processing dialog safely
      closeDialogSafely();

      // Update progress in dialog
      if (navigator.mounted) {
        if (result['success'] == true) {
          debugPrint('Campaign created successfully');
          _showSuccessDialog(dialogContext);
        } else {
          String errorMessage = result['message'] ??
              'Failed to create campaign. Please try again.';
          debugPrint('Campaign creation error: $errorMessage');
          // More helpful error message for users
          if (errorMessage.contains('404')) {
            errorMessage =
                'Server endpoint not found. Please verify the API configuration.';
          } else if (errorMessage.contains('Connection')) {
            errorMessage =
                'Network connection issue. Please check your internet connection and try again.';
          } else if (errorMessage.contains('Error:')) {
            // Format more technical errors in a user-friendly way
            errorMessage =
                'An error occurred while processing your request. Technical details have been logged for our team.';
          }
          _showErrorDialog(dialogContext, errorMessage);
        }
      }

      debugPrint('Campaign creation dialog flow completed');
    } catch (e, stackTrace) {
      // Additional error handling to catch any issues in the UI flow
      debugPrint('Exception in campaign creation UI flow: $e');
      debugPrint('Stack trace: $stackTrace');
      closeDialogSafely();

      // Show error dialog if navigator is still mounted
      if (navigator.mounted) {
        _showErrorDialog(dialogContext, 'An unexpected error occurred: $e');
      }
    }
  }

  // Very simple navigation that avoids BuildContext issues
  void _showSuccessDialog(BuildContext context) {
    debugPrint('Campaign created successfully - navigating to dashboard');

    // First close any open dialogs
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    // Then navigate directly to the dashboard after a brief delay
    Future.delayed(const Duration(milliseconds: 300), () {
      // Use a try-catch to handle any navigation issues
      try {
        // Use pushReplacement instead of pushAndRemoveUntil
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CompanyDashboardScreen()),
        );
      } catch (e) {
        debugPrint('Error during navigation: $e');
        // No fallback navigation needed - user can simply press back
      }
    });
  }

  // Safer error handling method that doesn't use BuildContext directly
  void _showErrorDialog(BuildContext context, String message) {
    // Just print error and return - we'll handle navigation separately
    debugPrint('Campaign creation error: $message');

    // Instead of trying to show a dialog, just print and return
    // The parent method will handle navigation
    return;
  }
}

class _ProcessingDialog extends StatefulWidget {
  final bool isDarkMode;
  final Color orangeColor;
  final String message;

  const _ProcessingDialog({
    Key? key,
    required this.isDarkMode,
    required this.orangeColor,
    required this.message,
  }) : super(key: key);

  @override
  _ProcessingDialogState createState() => _ProcessingDialogState();
}

class _ProcessingDialogState extends State<_ProcessingDialog> {
  String currentMessage = "";
  double progress = 0.0;
  bool showDebugInfo = false;

  @override
  void initState() {
    super.initState();
    currentMessage = widget.message;
  }

  void updateProgress(double value) {
    if (mounted) {
      setState(() {
        progress = value;
        if (value > 0) {
          currentMessage =
              "${widget.message} (${(value * 100).toStringAsFixed(0)}%)";
        }
      });
    }
  }

  void updateMessage(String message) {
    if (mounted) {
      setState(() {
        currentMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          progress > 0
              ? LinearProgressIndicator(
                  value: progress,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.orangeColor),
                  backgroundColor:
                      widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                )
              : CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(widget.orangeColor),
                ),
          const SizedBox(height: 16),
          Text(
            currentMessage,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (showDebugInfo) ...[
            const SizedBox(height: 8),
            Text(
              "If this is taking too long, check your network connection or file size",
              style: TextStyle(
                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                showDebugInfo = !showDebugInfo;
              });
            },
            child: Text(
              showDebugInfo ? "Hide Details" : "Show Details",
              style: TextStyle(
                color: widget.orangeColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


