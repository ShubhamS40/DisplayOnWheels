import 'package:flutter/material.dart';
import 'package:tsp/screens/driver/driver_dashboard.dart';
import 'package:tsp/screens/driver/driver_main_screen.dart';
import 'package:tsp/screens/driver/driver_upload_status_screen.dart';

class DocumentStatusScreen extends StatelessWidget {
  final Map<String, bool> documentStatus = {
    "Vehicle Documents": true,
    "ID Card": true,
    "Driving License": false,
    "Vehicle Image": true,
  };

  DocumentStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool allVerified = documentStatus.values.every((status) => status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Verification Status'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(allVerified),
            const SizedBox(height: 24),
            _buildDocumentsList(),
            const SizedBox(height: 100), // Spacing for bottom button
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ElevatedButton(
          onPressed: () {
            // Navigate to driver dashboard or next step
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DriverMainScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(bool allVerified) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: allVerified ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: allVerified ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            allVerified ? Icons.check_circle : Icons.warning,
            color: allVerified ? Colors.green : Colors.orange,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allVerified
                      ? 'All Documents Verified'
                      : 'Verification Pending',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: allVerified
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  allVerified
                      ? 'Your documents have been verified successfully.'
                      : 'Some documents are pending verification.',
                  style: TextStyle(
                    color: allVerified
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Document Status',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...documentStatus.entries
            .map((entry) => _buildDocumentItem(
                  entry.key,
                  entry.value,
                ))
            .toList(),
      ],
    );
  }

  Widget _buildDocumentItem(String documentName, bool isVerified) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.pending,
            color: isVerified ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              documentName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            isVerified ? 'Verified' : 'Pending',
            style: TextStyle(
              color: isVerified ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
