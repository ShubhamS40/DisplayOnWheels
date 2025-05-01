import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:tsp/screens/company/company_document/company_verification_stage.dart';
import 'dart:typed_data';

class CompanyDocumentReuploadScreen extends StatefulWidget {
  final String companyId;
  final String documentType; // companyRegistration, idCard, gstNumber
  final String documentName; // Display name for the document

  const CompanyDocumentReuploadScreen({
    Key? key,
    required this.companyId,
    required this.documentType,
    required this.documentName,
  }) : super(key: key);

  @override
  _CompanyDocumentReuploadScreenState createState() =>
      _CompanyDocumentReuploadScreenState();
}

class _CompanyDocumentReuploadScreenState
    extends State<CompanyDocumentReuploadScreen> {
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  // For preview
  File? selectedFile; // Mobile
  Uint8List? webImageBytes; // Web
  String? fileName;

  // Base64 for API
  String base64Image = "";

  @override
  void initState() {
    super.initState();
    // Show file picker immediately when screen opens
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        _showFilePickerDialog();
      }
    });
  }

  Future<void> _showFilePickerDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Wrap(
        children: [
          if (!kIsWeb)
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.orange),
              title: Text("Take Photo"),
              onTap: () async {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ListTile(
            leading: Icon(Icons.photo_library, color: Colors.blue),
            title: Text("Choose from Gallery"),
            onTap: () async {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (kIsWeb) {
        // Web-specific code for image picking
        XFile? pickedFile = await _picker.pickImage(
            source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);

        if (pickedFile != null) {
          final name = pickedFile.name;

          // Read file as bytes for preview
          final bytes = await pickedFile.readAsBytes();

          // Convert to base64 for API
          String image = base64Encode(bytes);

          setState(() {
            fileName = name;
            base64Image = image;
            webImageBytes = bytes;
          });
        }
      } else {
        // Mobile-specific code
        final pickedFile = await _picker.pickImage(
            source: source, maxWidth: 800, imageQuality: 80);

        if (pickedFile != null) {
          final imageFile = File(pickedFile.path);
          final name = path.basename(pickedFile.path);

          // Convert image to base64
          List<int> imageBytes = await imageFile.readAsBytes();
          String image = base64Encode(imageBytes);

          setState(() {
            selectedFile = imageFile;
            fileName = name;
            base64Image = image;
          });
        }
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  Future<void> _uploadDocument() async {
    if (base64Image.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a document to upload")),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      // Use the API endpoint shown in the Postman image
      final uri = Uri.parse(
          'http://localhost:5000/api/company-docs/update-document/${widget.companyId}');

      // Create a multipart request
      var request = http.MultipartRequest('PUT', uri);

      // Map the document type to match the exact backend expectations
      String backendDocType;
      switch(widget.documentType.toLowerCase()) {
        case 'companyregistration':
        case 'companyregdoc':
        case 'company registration':
          backendDocType = 'companyRegDoc';
          break;
        case 'idcard':
        case 'id card':
          backendDocType = 'idCard';
          break;
        case 'gstnumber':
        case 'gst number':
          backendDocType = 'gstNumber';  // Exactly matches what's in the API response
          break;
        default:
          backendDocType = widget.documentType;
      }
      
      // Add the document type field - field name matches what's in the Postman image
      request.fields['documentType'] = backendDocType;

      print("Uploading document with type: $backendDocType");

      // Add the file - the field name 'document' matches what's in the Postman image
      if (kIsWeb) {
        if (webImageBytes != null) {
          final multipartFile = http.MultipartFile.fromBytes(
            'document', // Field name seen in the Postman image
            webImageBytes!,
            filename: fileName ?? '${widget.documentType}.jpg',
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(multipartFile);
        }
      } else {
        if (selectedFile != null) {
          final mimeType = lookupMimeType(selectedFile!.path) ?? 'image/jpeg';
          final multipartFile = await http.MultipartFile.fromPath(
            'document', // Field name seen in the Postman image
            selectedFile!.path,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          );
          request.files.add(multipartFile);
        }
      }

      // Send the request
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          throw TimeoutException("Request timed out after 1 minute");
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      setState(() {
        isUploading = false;
      });

      if (response.statusCode == 200) {
        // Parse the response according to the format seen in the image
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final message = responseData['message'] ?? "Document updated successfully";
          
          // Check if document object is in the response
          if (responseData.containsKey('document')) {
            final Map<String, dynamic> documentData = responseData['document'];
            final String status = documentData['status'] ?? "PENDING";
            final String url = documentData['url'] ?? "";
            
            print("Document updated with status: $status");
            print("New document URL: $url");
          }
          
          // Show success message to user with a green background
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Return to document status screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CompanyDocumentStatusScreen()),
          );
        } catch (e) {
          print("Error parsing response: $e");
          // Still consider it successful if we can't parse the response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Document updated successfully"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Return to document status screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CompanyDocumentStatusScreen()),
          );
        }
      } else {
        // API error
        String errorMessage = "Upload failed";
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['error'] ??
              errorJson['message'] ??
              "Unknown server error";
        } catch (e) {
          errorMessage = "Upload failed: ${response.body}";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Re-upload ${widget.documentName}"),
        backgroundColor: Colors.blue.withOpacity(0.8),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Info card at the top
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "This document was rejected",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Please upload a new copy of your ${widget.documentName.toLowerCase()} that meets the requirements.",
                    style: TextStyle(
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),

            // Selected document preview
            GestureDetector(
              onTap: _showFilePickerDialog,
              child: Container(
                height: 250,
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: base64Image.isNotEmpty
                        ? Colors.green
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: base64Image.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Tap to select a document",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : kIsWeb
                        ? webImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  webImageBytes!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Container()
                        : selectedFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  selectedFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Container(),
              ),
            ),

            // File name display
            if (fileName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  fileName!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),

            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isUploading || base64Image.isEmpty ? null : _uploadDocument,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: isUploading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Submit Document",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            // Instructions
            Container(
              margin: EdgeInsets.only(top: 32),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Document Guidelines:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildGuidelineItem(
                      "Make sure the document is clearly visible"),
                  _buildGuidelineItem("All text should be readable"),
                  _buildGuidelineItem("Document should not be expired"),
                  _buildGuidelineItem("File size should be less than 5MB"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 18, color: Colors.blue.shade700),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
