import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DriverDocumentCard extends StatefulWidget {
  final String documentType;
  final String documentUrl;
  final String status;
  final String? rejectionReason;
  final Function(String status, String? reason)? onStatusChanged;

  const DriverDocumentCard({
    Key? key,
    required this.documentType,
    required this.documentUrl,
    required this.status,
    this.rejectionReason,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  State<DriverDocumentCard> createState() => _DriverDocumentCardState();
}

class _DriverDocumentCardState extends State<DriverDocumentCard> {
  late String selectedStatus;
  String? rejectionMessage;
  Uint8List? imageData;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.status;
    rejectionMessage = widget.rejectionReason;
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final response = await http.get(Uri.parse(widget.documentUrl));
      if (response.statusCode == 200) {
        setState(() {
          imageData = response.bodyBytes;
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.documentType,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(labelText: "Document Status"),
              items: const [
                DropdownMenuItem(value: "APPROVED", child: Text("Approved")),
                DropdownMenuItem(value: "REJECTED", child: Text("Rejected")),
                DropdownMenuItem(value: "PENDING", child: Text("Pending")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                  if (selectedStatus != 'REJECTED') {
                    rejectionMessage = null;
                  }
                });

                if (widget.onStatusChanged != null) {
                  widget.onStatusChanged!(
                      selectedStatus, rejectionMessage?.trim());
                }
              },
            ),
            if (selectedStatus == 'REJECTED')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextFormField(
                  initialValue: rejectionMessage,
                  onChanged: (value) {
                    rejectionMessage = value;
                    if (widget.onStatusChanged != null) {
                      widget.onStatusChanged!(
                          selectedStatus, rejectionMessage?.trim());
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: "Rejection Reason",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (isError || imageData == null) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text("Failed to load image")),
      );
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            insetPadding: const EdgeInsets.all(0),
            backgroundColor: Colors.black,
            child: Stack(
              children: [
                InteractiveViewer(
                  child: Center(
                    child: Image.memory(imageData!),
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 20,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Image.memory(
        imageData!,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
