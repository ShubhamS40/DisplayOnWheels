import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:tsp/screens/company/company_document/company_verification_stage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// API Config class
class ApiConfig {
  // Base URL for API calls
  static String baseUrl = kIsWeb
      ? 'http://3.110.135.112:5000' // For web browser testing
      : 'http://3.110.135.112:5000'; // For emulator testing

  // Company document upload endpoint
  static String get uploadCompanyDocumentsUrl =>
      '$baseUrl/api/company-docs/upload-company-documents';
}

// Define company type enum
enum CompanyType {
  Individual,
  Partnership,
  Corporation,
  Limited_Liability_Company,
  Non_Profit_Organization,
  Cooperative,
  Government_Agency,
  Other
}

// Convert enum values to user-friendly display names
String companyTypeToString(CompanyType type) {
  switch (type) {
    case CompanyType.Individual:
      return 'Individual';
    case CompanyType.Partnership:
      return 'Partnership';
    case CompanyType.Corporation:
      return 'Corporation';
    case CompanyType.Limited_Liability_Company:
      return 'Limited Liability Company';
    case CompanyType.Non_Profit_Organization:
      return 'Non-Profit Organization';
    case CompanyType.Cooperative:
      return 'Cooperative';
    case CompanyType.Government_Agency:
      return 'Government Agency';
    case CompanyType.Other:
      return 'Other';
  }
}

class CompanyDocumentUploadScreen extends StatefulWidget {
  final String companyId;

  const CompanyDocumentUploadScreen({super.key, this.companyId = ''});

  @override
  State<CompanyDocumentUploadScreen> createState() =>
      _CompanyDocumentUploadScreenState();
}

class _CompanyDocumentUploadScreenState
    extends State<CompanyDocumentUploadScreen> {
  // Document upload status tracking
  final Map<String, dynamic> documentFiles = {
    'Company Registration Document': null,
    'ID Card (Aadhar Card/ PAN Card)': null,
    'GST Number': null,
  };

  // For web uploads
  final Map<String, Uint8List> webImages = {};
  final Map<String, String> fileNames = {};
  final Map<String, String> base64Images = {};

  // Store company ID
  String _companyId = '';

  int get uploadedDocumentsCount =>
      documentFiles.values.where((file) => file != null).length;

  double get uploadProgress =>
      documentFiles.isEmpty ? 0 : uploadedDocumentsCount / documentFiles.length;

  // Company information controllers
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyAddressController =
      TextEditingController();
  final TextEditingController companyCityController = TextEditingController();
  final TextEditingController companyStateController = TextEditingController();
  final TextEditingController companyCountryController =
      TextEditingController();
  final TextEditingController companyZipCodeController =
      TextEditingController();

  // Selected company type
  CompanyType? selectedCompanyType;

  bool isLoading = false;
  String errorMessage = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadCompanyId();
  }

  Future<void> _loadCompanyId() async {
    // Use companyId passed from login or load from shared prefs
    if (widget.companyId.isNotEmpty) {
      setState(() {
        _companyId = widget.companyId;
      });
      print('Using companyId from constructor: $_companyId');
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        final companyId = prefs.getString('companyId');
        if (companyId != null && companyId.isNotEmpty) {
          setState(() {
            _companyId = companyId;
          });
          print('Loaded companyId from SharedPreferences: $_companyId');
        } else {
          print('No companyId found in SharedPreferences');
        }
      } catch (e) {
        print('Error loading companyId: $e');
      }
    }
  }

  @override
  void dispose() {
    companyNameController.dispose();
    companyAddressController.dispose();
    companyCityController.dispose();
    companyStateController.dispose();
    companyCountryController.dispose();
    companyZipCodeController.dispose();
    super.dispose();
  }

  // Function to pick image for document
  Future<void> _pickDocument(String documentType) async {
    try {
      final ImagePicker picker = ImagePicker();

      if (kIsWeb) {
        // Web implementation
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          // For web we need to read the file differently
          final fileName = pickedFile.name;
          print("Web - Image picked: $fileName");

          // Read file as bytes for preview and API
          final bytes = await pickedFile.readAsBytes();

          // Convert to base64 for API
          String base64Image = base64Encode(bytes);

          setState(() {
            // Store references
            documentFiles[documentType] = 'web';
            webImages[documentType] = bytes;
            fileNames[documentType] = fileName;
            base64Images[documentType] = base64Image;
          });
        }
      } else {
        // Mobile implementation
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (image != null) {
          final file = File(image.path);
          final fileName = path.basename(file.path);

          setState(() {
            documentFiles[documentType] = file;
          });
        }
      }
    } catch (e) {
      print('Error picking document: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking document: $e")),
      );
    }
  }

  // Function to submit documents and company info
  Future<void> _submitDocuments() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if all required documents are selected
    if (documentFiles.values.any((file) => file == null)) {
      setState(() {
        errorMessage = 'Please select all required documents';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Create form data object that exactly matches the structure in Postman
      final dio = Dio();
      
      // Set longer timeout for uploads
      dio.options.connectTimeout = const Duration(minutes: 3);
      dio.options.receiveTimeout = const Duration(minutes: 3);
      dio.options.sendTimeout = const Duration(minutes: 3);
      
      // Debug log
      print("API URL: ${ApiConfig.uploadCompanyDocumentsUrl}");
      print("Company ID: $_companyId");
      
      // Create FormData exactly as shown in Postman
      final formData = FormData();
      
      // Add text fields - Exact order and naming as shown in Postman
      formData.fields.addAll([
        MapEntry('companyId', _companyId),
        MapEntry('companyName', companyNameController.text.trim()),
        MapEntry('companyType', selectedCompanyType.toString().split('.').last),
        MapEntry('companyAddress', companyAddressController.text.trim()),
        MapEntry('companyCity', companyCityController.text.trim()),
        MapEntry('companyState', companyStateController.text.trim()),
        MapEntry('companyCountry', companyCountryController.text.trim()),
        MapEntry('companyZipCode', companyZipCodeController.text.trim()),
      ]);
      
      // Document field names as shown in Postman
      final documentFieldMap = {
        "Company Registration Document": "companyRegistrationDoc",
        "ID Card (Aadhar Card/ PAN Card)": "idCard",
        "GST Number": "gstNumberDoc",
      };
      
      // Add file fields exactly as in Postman
      for (final entry in documentFiles.entries) {
        if (entry.value != null) {
          final localFieldName = entry.key;
          final postmanFieldName = documentFieldMap[localFieldName]!;
          
          print("Processing document: $localFieldName -> $postmanFieldName");
          
          if (kIsWeb && entry.value == 'web') {
            final bytes = webImages[localFieldName];
            final fileName = fileNames[localFieldName] ?? "document.jpg";
            
            if (bytes != null) {
              print("Adding web file: $fileName as $postmanFieldName");
              formData.files.add(
                MapEntry(
                  postmanFieldName,
                  MultipartFile.fromBytes(
                    bytes,
                    filename: fileName,
                  ),
                ),
              );
            }
          } else if (!kIsWeb) {
            final file = entry.value as File;
            final fileName = path.basename(file.path);
            
            print("Adding mobile file: $fileName as $postmanFieldName");
            formData.files.add(
              MapEntry(
                postmanFieldName,
                await MultipartFile.fromFile(
                  file.path,
                  filename: fileName,
                ),
              ),
            );
          }
        }
      }
      
      // Log the request details for debugging
      print("Sending request with data:");
      for (var field in formData.fields) {
        print("Field: ${field.key} = ${field.value}");
      }
      for (var file in formData.files) {
        print("File: ${file.key} = ${file.value.filename}");
      }
      
      // Add headers if needed
      final headers = {
        'Accept': '*/*',
      };
      
      // Make the API call
      final response = await dio.post(
        ApiConfig.uploadCompanyDocumentsUrl,
        data: formData,
        options: Options(headers: headers),
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(0);
          print('Upload progress: $progress%');
        },
      );
      
      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");
      
      // Handle the response
      setState(() {
        isLoading = false;
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documents submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to document verification status screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CompanyDocumentStatusScreen(),
          ),
        );
      } else {
        // API error handling
        String errorMsg = "Upload failed";
        
        if (response.data is Map) {
          errorMsg = response.data['message'] ?? response.data['error'] ?? errorMsg;
        } else if (response.data is String && response.data.isNotEmpty) {
          errorMsg = response.data;
        } else {
          errorMsg = "Server error: HTTP ${response.statusCode}";
        }
        
        setState(() {
          errorMessage = errorMsg;
        });
      }
    } catch (e) {
      print('Error submitting documents: $e');
      
      setState(() {
        isLoading = false;
        
        if (e is DioError || e is DioException) {
          final dioError = e as dynamic;
          
          if (dioError.type == DioErrorType.connectionTimeout ||
              dioError.type == DioExceptionType.connectionTimeout) {
            errorMessage = 'Connection timed out. Please try again.';
          } else if (dioError.response != null) {
            final data = dioError.response?.data;
            errorMessage = 'Upload failed: ';
            
            if (data is Map) {
              errorMessage += data['message'] ?? data['error'] ?? 'Server error';
            } else if (data is String && data.isNotEmpty) {
              errorMessage += data;
            } else {
              errorMessage += 'Server error ${dioError.response?.statusCode}';
            }
          } else {
            errorMessage = 'Network error: ${dioError.message}';
          }
        } else {
          errorMessage = 'An error occurred: $e';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Verification'),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 120,
                              width: 120,
                              child: CircularProgressIndicator(
                                value: uploadProgress,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.orange),
                                strokeWidth: 8.0,
                              ),
                            ),
                            Center(
                              child: Text(
                                '${(uploadProgress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Document upload section
                ...documentFiles.entries.map((entry) {
                  final docType = entry.key;
                  final file = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: cardColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        docType,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: file != null
                          ? Text(
                              'File uploaded',
                              style: TextStyle(
                                color: Colors.green,
                              ),
                            )
                          : null,
                      trailing: IconButton(
                        icon: Icon(
                          Icons.file_upload_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () => _pickDocument(docType),
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Company information section
                Text(
                  'Company Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Company Name
                TextFormField(
                  controller: companyNameController,
                  decoration: InputDecoration(
                    labelText: 'Company Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter company name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Company Type
                DropdownButtonFormField<CompanyType>(
                  decoration: InputDecoration(
                    labelText: 'Company Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  value: selectedCompanyType,
                  items: CompanyType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(companyTypeToString(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCompanyType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select company type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Company Address
                TextFormField(
                  controller: companyAddressController,
                  decoration: InputDecoration(
                    labelText: 'Company Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter company address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // City and State in a row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: companyCityController,
                        decoration: InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: companyStateController,
                        decoration: InputDecoration(
                          labelText: 'State',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Country and Zip Code in a row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: companyCountryController,
                        decoration: InputDecoration(
                          labelText: 'Country',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: companyZipCodeController,
                        decoration: InputDecoration(
                          labelText: 'Zip Code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                // Error message
                if (errorMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Submit button
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitDocuments,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
