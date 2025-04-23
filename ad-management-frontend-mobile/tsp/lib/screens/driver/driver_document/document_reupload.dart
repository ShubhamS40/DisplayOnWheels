import 'dart:io';
import 'dart:convert';
import 'dart:async'; // Add this import for TimeoutException
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:tsp/screens/driver/driver_document/documentVerification_Stage.dart';
import 'dart:typed_data';

class DocumentReuploadScreen extends StatefulWidget {
  final String driverId;
  final String
      documentType; // photo, idCard, drivingLicense, vehicleImage, bankProof
  final String documentName; // Display name for the document

  const DocumentReuploadScreen({
    Key? key,
    required this.driverId,
    required this.documentType,
    required this.documentName,
  }) : super(key: key);

  @override
  _DocumentReuploadScreenState createState() => _DocumentReuploadScreenState();
}

class _DocumentReuploadScreenState extends State<DocumentReuploadScreen> {
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
      // Use the API endpoint for updating a single document
      final uri = Uri.parse(
          'http://localhost:5000/api/driver/update-document/${widget.driverId}');

      // Create a multipart request
      var request = http.MultipartRequest('PUT', uri);

      // Add the document type field
      request.fields['documentType'] = widget.documentType;

      // Add the file
      if (kIsWeb) {
        if (webImageBytes != null) {
          final multipartFile = http.MultipartFile.fromBytes(
            'document',
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
            'document',
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

      setState(() {
        isUploading = false;
      });

      if (response.statusCode == 200) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Document re-uploaded successfully!")),
        );

        // Return to document status screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DocumentStatusScreen()),
        );
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
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Re-upload ${widget.documentName}"),
        backgroundColor: Colors.red.withOpacity(0.8),
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
                  backgroundColor: Colors.green,
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

            // Secondary action - select different document
            TextButton.icon(
              onPressed: isUploading ? null : _showFilePickerDialog,
              icon: Icon(Icons.photo_library),
              label: Text("Select Different Document"),
            ),
          ],
        ),
      ),
    );
  }
}
