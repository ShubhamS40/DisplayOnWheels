import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tsp/screens/driver/document_status_screen.dart';
import 'package:tsp/screens/driver/driver_dashboard.dart';

class DriverVerificationScreen extends StatefulWidget {
  @override
  _DriverVerificationScreenState createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState extends State<DriverVerificationScreen> {
  double uploadProgress = 0.0; // Tracks upload progress
  Map<String, bool> uploadedDocs = {
    "Vehicle Documents": false,
    "ID Card (Aadhar Card/PAN Card)": false,
    "Driving License": false,
    "Vehicle Image": false,
  };

  final ImagePicker _picker = ImagePicker();

  // Function to open dialog and choose image source

  Future<void> _showFilePickerDialog(String docType) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Adjusts height dynamically
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3, // Starts at 30% of screen height
          minChildSize: 0.2, // Minimum size
          maxChildSize: 0.5, // Maximum size for scroll
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Adjusts based on content
                  children: [
                    Text(
                      "Upload $docType",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 15),
                    ListTile(
                      leading:
                          const Icon(Icons.camera_alt, color: Colors.orange),
                      title: const Text("Take Photo"),
                      onTap: () async {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera, docType);
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.photo_library, color: Colors.blue),
                      title: const Text("Choose from Gallery"),
                      onTap: () async {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery, docType);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Function to handle image selection
  Future<void> _pickImage(ImageSource source, String docType) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        uploadedDocs[docType] = true;
        uploadProgress =
            uploadedDocs.values.where((v) => v).length / uploadedDocs.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Driver Verification",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Circular Progress Indicator (Bigger & Adjusted)
            Center(
              child: CircularPercentIndicator(
                radius: 110.0, // Increased radius
                lineWidth: 14.0, // Thicker border
                percent: uploadProgress,
                center: Text(
                  "${(uploadProgress * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 26, // Bigger Font
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                progressColor: Colors.orange,
                backgroundColor:
                    isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            const SizedBox(height: 30),

            // Document Upload Fields
            Column(
              children: uploadedDocs.keys.map((docType) {
                bool isUploaded = uploadedDocs[docType]!;
                return GestureDetector(
                  onTap: () => _showFilePickerDialog(docType),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isUploaded
                          ? Colors.green.withOpacity(0.1)
                          : (isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isUploaded
                            ? Colors.green
                            : (isDarkMode
                                ? Colors.white70
                                : Colors.grey.shade400),
                        width: 1.8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          docType,
                          style: TextStyle(
                            fontSize: 16,
                            color: isUploaded
                                ? Colors.green
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          isUploaded ? Icons.check_circle : Icons.cloud_upload,
                          color: isUploaded
                              ? Colors.green
                              : (isDarkMode
                                  ? Colors.white70
                                  : Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),

            // Continue Button
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: uploadProgress == 1.0
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DocumentStatusScreen(),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  disabledBackgroundColor:
                      isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
