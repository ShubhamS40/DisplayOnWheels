import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:mime/mime.dart';
import 'package:tsp/screens/driver/driver_document/documentVerification_Stage.dart';
// For web
import 'dart:html' as html show File, FileReader, window;
import 'dart:typed_data';

// Add a configuration class for API settings
class ApiConfig {
  // Change this to your server's IP or hostname when testing
  // Use your computer's IP address when testing on a physical device or browser
  // Use 10.0.2.2 when testing on Android emulator to connect to localhost
  // Use localhost when testing on iOS simulator or web on the same machine
  static String baseUrl = kIsWeb
      ? 'http://localhost:5000' // For web browser testing
      : 'http://10.0.2.2:5000'; // For emulator testing

  // For specific environments, you can override:
  // static String baseUrl = 'http://192.168.X.X:5000'; // Replace with your IP

  static String get uploadDocumentsUrl =>
      '$baseUrl/api/driver-docs/upload-driver-documents';
}

class DriverVerificationScreen extends StatefulWidget {
  final String driverId;
  final String? initialDocumentToUpload;

  DriverVerificationScreen({
    required this.driverId,
    this.initialDocumentToUpload,
  });

  @override
  _DriverVerificationScreenState createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState extends State<DriverVerificationScreen> {
  double uploadProgress = 0.0;
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  // For Web
  Map<String, Uint8List?> webImages = {};

  // Document files (Only used in mobile)
  Map<String, File?> selectedFiles = {
    "photo": null,
    "idCard": null,
    "drivingLicense": null,
    "vehicleImage": null,
    "bankProof": null,
  };

  // Base64 encoded images
  Map<String, String> base64Images = {
    "photo": "",
    "idCard": "",
    "drivingLicense": "",
    "vehicleImage": "",
    "bankProof": "",
  };

  // Track file names for display
  Map<String, String> fileNames = {
    "photo": "",
    "idCard": "",
    "drivingLicense": "",
    "vehicleImage": "",
    "bankProof": "",
  };

  // Bank input fields
  final accountNumberController = TextEditingController();
  final bankNameController = TextEditingController();
  final branchNameController = TextEditingController();
  final ifscCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add listeners to all text controllers to update state when text changes
    accountNumberController.addListener(_updateSubmitState);
    bankNameController.addListener(_updateSubmitState);
    branchNameController.addListener(_updateSubmitState);
    ifscCodeController.addListener(_updateSubmitState);

    // If initialDocumentToUpload is provided, open document picker after a short delay
    if (widget.initialDocumentToUpload != null) {
      // Use a short delay to allow the screen to build first
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          _showFilePickerDialog(widget.initialDocumentToUpload!);
        }
      });
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    accountNumberController.dispose();
    bankNameController.dispose();
    branchNameController.dispose();
    ifscCodeController.dispose();
    super.dispose();
  }

  // Updates state when any text field changes
  void _updateSubmitState() {
    setState(() {
      // This will update the UI when text fields change
    });
  }

  // Calculate current progress
  void _updateProgress() {
    int count = 0;
    if (kIsWeb) {
      base64Images.forEach((key, value) {
        if (value.isNotEmpty) count++;
      });
    } else {
      selectedFiles.forEach((key, value) {
        if (value != null) count++;
      });
    }
    setState(() {
      uploadProgress =
          count / (kIsWeb ? base64Images.length : selectedFiles.length);
    });
    print("Progress updated: $uploadProgress ($count/${selectedFiles.length})");
  }

  // Check if all required fields are filled
  bool get _areAllFieldsFilled =>
      accountNumberController.text.isNotEmpty &&
      bankNameController.text.isNotEmpty &&
      branchNameController.text.isNotEmpty &&
      ifscCodeController.text.isNotEmpty;

  // Check if all required documents are uploaded
  bool get _areAllDocumentsUploaded {
    if (kIsWeb) {
      return !base64Images.values.any((image) => image.isEmpty);
    } else {
      return !selectedFiles.values.any((file) => file == null);
    }
  }

  // Pick Image
  Future<void> _showFilePickerDialog(String docType) async {
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
                _pickImage(ImageSource.camera, docType);
              },
            ),
          ListTile(
            leading: Icon(Icons.photo_library, color: Colors.blue),
            title: Text("Choose from Gallery"),
            onTap: () async {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery, docType);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, String docType) async {
    try {
      if (kIsWeb) {
        // Web-specific code for image picking
        XFile? pickedFile = await _picker.pickImage(
            source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);

        if (pickedFile != null) {
          final fileName = pickedFile.name;
          print("Web - Image picked: $fileName");

          // Read file as bytes for preview
          final bytes = await pickedFile.readAsBytes();

          // Convert to base64 for API
          String base64Image = base64Encode(bytes);

          setState(() {
            // Store filename and base64
            fileNames[docType] = fileName;
            base64Images[docType] = base64Image;
            // Store bytes for image preview
            webImages[docType] = bytes;
          });

          _updateProgress();
        }
      } else {
        // Mobile-specific code
        final pickedFile = await _picker.pickImage(
            source: source, maxWidth: 800, imageQuality: 80);

        if (pickedFile != null) {
          final imageFile = File(pickedFile.path);
          final fileName = path.basename(pickedFile.path);

          print("Mobile - Image picked: $fileName");

          // Convert image to base64
          List<int> imageBytes = await imageFile.readAsBytes();
          String base64Image = base64Encode(imageBytes);

          setState(() {
            selectedFiles[docType] = imageFile;
            base64Images[docType] = base64Image;
            fileNames[docType] = fileName;
          });

          // Update progress separately to ensure UI refreshes
          _updateProgress();
        }
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  Future<void> uploadDocumentToServer() async {
    // Double-check validation before upload
    if (!_areAllDocumentsUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload all required documents.")),
      );
      return;
    }

    if (!_areAllFieldsFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all bank details.")),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      // Get API URL from config
      final uri = Uri.parse(ApiConfig.uploadDocumentsUrl);

      // For debugging - log the request
      print("Sending request to: $uri");
      print("Driver ID: ${widget.driverId}");

      // Switch to multipart/form-data for larger file uploads
      var request = http.MultipartRequest('POST', uri);

      // Add the form fields - IMPORTANT: these exact field names match backend expectations
      request.fields['driverId'] = widget.driverId;
      request.fields['accountNumber'] = accountNumberController.text.trim();
      request.fields['bankName'] = bankNameController.text.trim();
      request.fields['branchName'] = branchNameController.text.trim();
      request.fields['ifscCode'] = ifscCodeController.text.trim();

      // Create mapping for form field names that match backend expectations
      final fieldMapping = {
        "photo": "photo",
        "idCard": "idCard",
        "drivingLicense": "drivingLicense",
        "vehicleImage": "vehicleImage",
        "bankProof": "bankProof",
      };

      // Add base64 images to multipart request
      for (var entry in base64Images.entries) {
        final localFieldName = entry.key;
        final postmanFieldName = fieldMapping[localFieldName] ?? localFieldName;
        final base64Image = entry.value;

        if (base64Image.isNotEmpty) {
          print("Adding ${postmanFieldName} to request");

          if (kIsWeb) {
            // For web, convert base64 back to bytes and add as file
            Uint8List bytes = webImages[localFieldName] ?? Uint8List(0);
            final fileName =
                fileNames[localFieldName] ?? "${localFieldName}.jpg";

            final multipartFile = http.MultipartFile.fromBytes(
              postmanFieldName,
              bytes,
              filename: fileName,
              contentType: MediaType('image', 'jpeg'),
            );
            request.files.add(multipartFile);
          } else {
            // For mobile, add the actual file
            final file = selectedFiles[localFieldName];
            if (file != null) {
              final fileName = path.basename(file.path);
              final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';

              final multipartFile = await http.MultipartFile.fromPath(
                postmanFieldName,
                file.path,
                filename: fileName,
                contentType: MediaType.parse(mimeType),
              );
              request.files.add(multipartFile);
            }
          }
        }
      }

      print("Sending ${request.files.length} files");

      // Send the request
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          throw TimeoutException("Request timed out after 2 minutes");
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      setState(() {
        isUploading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Documents uploaded successfully!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DocumentStatusScreen()),
        );
      } else {
        // API error with detailed message
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
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                uploadDocumentToServer();
              },
            ),
          ),
        );
      }
    } catch (e) {
      print("Upload error: $e");
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              uploadDocumentToServer();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine whether Submit button should be enabled
    final bool isSubmitEnabled = !isUploading && (_areAllFieldsFilled || true);

    return Scaffold(
      appBar: AppBar(
        title: Text("Driver Verification"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircularPercentIndicator(
                  radius: 100,
                  percent: uploadProgress,
                  lineWidth: 12,
                  progressColor: Colors.orange,
                  backgroundColor:
                      isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  center: Text(
                    "${(uploadProgress * 100).toInt()}%",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 30),

                // ✅ File Uploads
                ...selectedFiles.keys.map((type) {
                  final uploaded = kIsWeb
                      ? base64Images[type]!.isNotEmpty
                      : selectedFiles[type] != null;
                  final fileName = fileNames[type] ?? "";

                  return GestureDetector(
                    onTap: () => _showFilePickerDialog(type),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: uploaded
                            ? Colors.green.withOpacity(0.1)
                            : (isDark ? Colors.grey[800] : Colors.grey[100]),
                        border: Border.all(
                          color: uploaded
                              ? Colors.green
                              : (isDark
                                  ? Colors.white70
                                  : Colors.grey.shade400),
                          width: 1.8,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getDisplayName(type),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: uploaded
                                      ? Colors.green
                                      : Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                ),
                              ),
                              Icon(uploaded
                                  ? Icons.check_circle
                                  : Icons.cloud_upload),
                            ],
                          ),
                          if (uploaded && fileName.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                fileName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (uploaded)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: kIsWeb
                                    ? webImages[type] != null
                                        ? Image.memory(
                                            webImages[type]!,
                                            height: 80,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            height: 80,
                                            color: Colors.grey.shade200)
                                    : Image.file(
                                        selectedFiles[type]!,
                                        height: 80,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // ✅ Bank Detail Fields
                _buildTextField("Account Number",
                    controller: accountNumberController),
                _buildTextField("Bank Name", controller: bankNameController),
                _buildTextField("Branch Name",
                    controller: branchNameController),
                _buildTextField("IFSC Code", controller: ifscCodeController),

                const SizedBox(height: 30),

                // ✅ Submit Button - Always enabled if not uploading
                ElevatedButton(
                  onPressed: isSubmitEnabled ? uploadDocumentToServer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Center(
                    child: Text(isUploading ? "Uploading..." : "Submit",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),

          // Loading Overlay
          if (isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to display user-friendly document names
  String _getDisplayName(String type) {
    switch (type) {
      case 'photo':
        return 'Driver Photo';
      case 'idCard':
        return 'ID Card';
      case 'drivingLicense':
        return 'Driving License';
      case 'vehicleImage':
        return 'Vehicle Image';
      case 'bankProof':
        return 'Bank Proof';
      default:
        return type;
    }
  }

  Widget _buildTextField(String label,
      {required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
