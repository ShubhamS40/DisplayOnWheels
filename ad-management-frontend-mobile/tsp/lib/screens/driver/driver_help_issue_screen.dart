import 'package:flutter/material.dart';

class DriverHelpIssueScreen extends StatefulWidget {
  const DriverHelpIssueScreen({Key? key}) : super(key: key);

  @override
  State<DriverHelpIssueScreen> createState() => _DriverHelpIssueScreenState();
}

class _DriverHelpIssueScreenState extends State<DriverHelpIssueScreen> {
  String _selectedIssue = 'Advertisement poster is removed';
  bool _hasUploadedPhoto = false;

  // Orange color for the theme
  static const Color primaryOrange = Color(0xFFFF7F00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading:
            false, // Don't show back button when in main navigation
        title: Text(
          'Driver Help & Issue Reporting',
          style: TextStyle(
            color: primaryOrange,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppIdentification(),
              const SizedBox(height: 20),
              _buildIssueSelection(),
              const SizedBox(height: 24),
              _buildUploadProof(),
              const SizedBox(height: 24),
              _buildResolutionSteps(),
              const SizedBox(height: 24),
              _buildAdminContactDetails(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppIdentification() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF5F5F5),
          ),
          child: const Center(
            child: Text(
              'L',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Livertise App',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Report Advertisement Issue',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIssueSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Issue Selection',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildIssueOption(
          'Advertisement poster is removed',
          Icons.check_circle,
          const Color(0xFF00A3E0),
        ),
        _buildIssueOption(
          'Board lighting is not working',
          null,
          null,
        ),
        GestureDetector(
          onTap: () {
            // Show dialog to enter custom issue
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: const [
                Icon(Icons.add, size: 20, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Select one of the options or describe a custom issue',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIssueOption(String title, IconData? icon, Color? iconColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIssue = title;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            icon != null
                ? Icon(icon, size: 24, color: iconColor)
                : Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 1.5),
                    ),
                  ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProof() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Proof',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Implement retake photo function
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryOrange,
                  elevation: 0,
                  side: BorderSide(color: primaryOrange, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Retake'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Implement submit photo function
                  setState(() {
                    _hasUploadedPhoto = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Submit Photo'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResolutionSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resolution Steps',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Guidelines',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Fix the issue     Contact support',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 8),
              Text(
                'Follow the guidelines to resolve the issue. If you need help, contact support.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminContactDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Contact Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: const Icon(
                Icons.email_outlined,
                size: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Email: admin@example.com',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red[50],
              ),
              child: const Icon(
                Icons.phone_outlined,
                size: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Phone: +1234567890',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Implement reupload ad proof function
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryOrange,
              elevation: 0,
              side: BorderSide(color: primaryOrange, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Reupload Ad Proof'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _hasUploadedPhoto
                ? () {
                    // Implement submit ticket function
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Submit Ticket'),
          ),
        ),
      ],
    );
  }
}
