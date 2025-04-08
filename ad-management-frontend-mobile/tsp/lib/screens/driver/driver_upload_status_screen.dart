import 'package:flutter/material.dart';
import 'driver_main_screen.dart';

class DriverUploadStatusScreen extends StatefulWidget {
  final String status;

  const DriverUploadStatusScreen({Key? key, this.status = 'Pending'})
      : super(key: key);

  @override
  State<DriverUploadStatusScreen> createState() =>
      _DriverUploadStatusScreenState();
}

class _DriverUploadStatusScreenState extends State<DriverUploadStatusScreen> {
  late String _status;
  static const Color primaryOrange = Color(0xFFFF7F00);

  @override
  void initState() {
    super.initState();
    _status = widget.status;

    // Simulate status change after 3 seconds (for demo purposes only)
    if (_status == 'Pending') {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _status = 'Approved';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advertisement Status'),
        backgroundColor: primaryOrange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              _buildStatusIcon(),
              const SizedBox(height: 30),
              Text(
                'Your advertisement proof is $_status',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildStatusDetails(),
              const SizedBox(height: 40),
              if (_status == 'Approved') _buildApprovedButton(context),
              if (_status == 'Pending') _buildPendingButton(),
              if (_status == 'Rejected') _buildRejectedButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    double size = 100;

    switch (_status) {
      case 'Approved':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'Rejected':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.access_time;
        color = Colors.orange;
    }

    return Icon(
      icon,
      size: size,
      color: color,
    );
  }

  Widget _buildStatusDetails() {
    String message;

    switch (_status) {
      case 'Approved':
        message =
            'Your advertisement proof has been approved by our team. You can now continue to the dashboard.';
        break;
      case 'Rejected':
        message =
            'Your advertisement proof was rejected. Please review the feedback and upload a new proof.';
        break;
      default:
        message =
            'Your advertisement proof is being reviewed by our team. This usually takes 1-2 business days.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildApprovedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to DriverMainScreen and clear navigation stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DriverMainScreen(),
            ),
            (route) => false, // This removes all previous routes
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Continue to Dashboard',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPendingButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null, // Disabled button
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          disabledBackgroundColor: Colors.grey[400],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Waiting for Approval',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRejectedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Go back to upload screen
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Upload New Proof',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
