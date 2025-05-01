import 'package:flutter/material.dart';
import 'package:tsp/widgets/full_screen_image_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyDocumentsCard extends StatelessWidget {
  final Map<String, dynamic> companyData;
  final Map<String, String> docStatus;
  final Function(String, String, [String?]) onStatusUpdate;

  const CompanyDocumentsCard({
    Key? key,
    required this.companyData,
    required this.docStatus,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define the correct mapping between display names, URL keys and status keys
    final documentMap = [
      {
        'title': 'Company Registration Document',
        'urlKey': 'companyRegistrationUrl',
        'statusKey': 'companyRegistrationStatus',
        'apiType': 'companyRegDoc'
      },
      {
        'title': 'ID Card (Aadhar Card/PAN Card)',
        'urlKey': 'idCardUrl',
        'statusKey': 'idCardStatus',
        'apiType': 'idCard'
      },
      {
        'title': 'GST Number',
        'urlKey': 'gstNumberUrl',
        'statusKey': 'gstNumberStatus',
        'apiType': 'gstNumber'
      },
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.file_copy, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Company Documents',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            // Build document sections dynamically
            ...documentMap.map((doc) => Column(
              children: [
                _buildDocumentSection(
                  context,
                  doc['title']!,
                  doc['urlKey']!,
                  doc['statusKey']!,
                ),
                if (doc != documentMap.last) const Divider(),
              ],
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentSection(
    BuildContext context,
    String documentTitle,
    String urlKey,
    String statusKey,
  ) {
    final String documentUrl = companyData[urlKey] ?? '';
    final String currentStatus = docStatus[statusKey] ?? 'PENDING';
    
    // Enhanced logging for image URL and status
    print("Building document section: $documentTitle");
    print("URL key: $urlKey, URL value: $documentUrl");
    print("Status key: $statusKey, Status value: $currentStatus");
    
    // Check if the document data exists in companyData and print keys
    print("Available keys in companyData: ${companyData.keys.toList()}");
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            documentTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        
        // Document preview
        if (documentUrl.isNotEmpty)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImageViewer(
                    imageUrl: documentUrl,
                    title: documentTitle,
                  ),
                ),
              );
            },
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Hero(
                      tag: documentUrl,
                      child: Image.network(
                        documentUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        headers: const {
                          // Add headers if needed for S3 authentication
                          'Accept': 'image/jpeg,image/png,image/jpg,*/*',
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: const Color(0xFFFF5722),
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Loading image...',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading image from URL: $documentUrl");
                          print("Error details: $error");
                          print("Stack trace: $stackTrace");
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image, size: 42, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  'Image not available',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 4),
                                TextButton(
                                  onPressed: () {
                                    print("Trying to open URL in browser: $documentUrl");
                                    // Open the URL directly in browser
                                    final Uri uri = Uri.parse(documentUrl);
                                    launchUrl(uri, mode: LaunchMode.externalApplication)
                                      .then((launched) => print("Launch success: $launched"))
                                      .catchError((e) => print("Launch error: $e"));
                                  },
                                  child: Text(
                                    'Open in Browser',
                                    style: TextStyle(
                                      color: const Color(0xFFFF5722),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Overlay indicator to show the image is tappable
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('No document uploaded'),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Status and action buttons
        Row(
          children: [
            _buildStatusChip(currentStatus),
            const Spacer(),
            _buildActionButtons(context, statusKey, currentStatus),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String statusText;

    switch (status) {
      case 'APPROVED':
        chipColor = Colors.green;
        statusText = 'Approved';
        break;
      case 'REJECTED':
        chipColor = Colors.red;
        statusText = 'Rejected';
        break;
      case 'PENDING':
      default:
        chipColor = Colors.orange;
        statusText = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        border: Border.all(color: chipColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: chipColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String statusKey, String currentStatus) {
    return Row(
      children: [
        // Approve button
        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Approve'),
          style: ElevatedButton.styleFrom(
            backgroundColor: currentStatus == 'APPROVED' ? Colors.green : Colors.grey.shade200,
            foregroundColor: currentStatus == 'APPROVED' ? Colors.white : Colors.black,
          ),
          onPressed: () {
            // Debug print before status update
            print("Before approval: statusKey=$statusKey, currentStatus=$currentStatus");
            onStatusUpdate(statusKey, 'APPROVED');
            
            // Log that the approval button was pressed
            print("Approve button pressed for $statusKey -> APPROVED");
          },
        ),
        const SizedBox(width: 8),
        
        // Reject button
        ElevatedButton.icon(
          icon: const Icon(Icons.close),
          label: const Text('Reject'),
          style: ElevatedButton.styleFrom(
            backgroundColor: currentStatus == 'REJECTED' ? Colors.red : Colors.grey.shade200,
            foregroundColor: currentStatus == 'REJECTED' ? Colors.white : Colors.black,
          ),
          onPressed: () {
            // Log that the reject button was pressed
            print("Reject button pressed for $statusKey");
            _showRejectDialog(context, statusKey);
          },
        ),
      ],
    );
  }

  void _showRejectDialog(BuildContext context, String statusKey) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for rejection'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              // Debug print before status update
              print("Before rejection: statusKey=$statusKey, reason=$reason");
              onStatusUpdate(statusKey, 'REJECTED', reason);
              
              // Log that rejection was confirmed
              print("Rejection confirmed for $statusKey -> REJECTED with reason: $reason");
              
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Reject',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
