import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CompanyVerificationScreen extends StatefulWidget {
  @override
  _CompanyVerificationScreenState createState() =>
      _CompanyVerificationScreenState();
}

class _CompanyVerificationScreenState extends State<CompanyVerificationScreen> {
  double uploadProgress = 0.0; // Tracks upload progress
  final ImagePicker _picker = ImagePicker();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController registrationNumberController =
      TextEditingController();
  final TextEditingController officeAddressController = TextEditingController();

  Map<String, bool> uploadedDocs = {
    "GST Certificate": false,
    "Company Incorporation Certificate": false,
    "Company PAN Card": false,
  };

  // Function to open dialog and choose image source
  Future<void> _showFilePickerDialog(String docType) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Fixes overflow issue
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3, // Starts at 30% of screen height
          minChildSize: 0.2,
          maxChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context)
                  .iconTheme
                  .color), // Dynamically set icon color
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Company Document Verification",
          style: TextStyle(
            color: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.color, // Dynamically set text color
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Circular Progress Indicator (Bigger & Thicker)
              CircularPercentIndicator(
                radius: 100.0, // Bigger radius
                lineWidth: 14.0, // Thicker border
                percent: uploadProgress,
                center: Text(
                  "${(uploadProgress * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 24, // Bigger Font
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                progressColor: Colors.orange,
                backgroundColor: Colors.grey.shade300,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(height: 30),

              // Company Name Input Field
              TextField(
                controller: companyNameController,
                decoration: InputDecoration(
                  labelText: "Company Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 15),

              // Business Registration Number
              TextField(
                controller: registrationNumberController,
                decoration: InputDecoration(
                  labelText: "Business Registration Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.confirmation_number),
                ),
              ),
              const SizedBox(height: 15),

              // Office Address Input Field
              TextField(
                controller: officeAddressController,
                decoration: InputDecoration(
                  labelText: "Office Address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 20),

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
                            ? Colors.green.shade100
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              isUploaded ? Colors.green : Colors.grey.shade400,
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
                              color: isUploaded ? Colors.green : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            isUploaded
                                ? Icons.check_circle
                                : Icons.cloud_upload,
                            color: isUploaded
                                ? Colors.green
                                : Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (uploadProgress == 1.0 &&
                          companyNameController.text.isNotEmpty &&
                          registrationNumberController.text.isNotEmpty &&
                          officeAddressController.text.isNotEmpty)
                      ? () {}
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.grey.shade400,
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
      ),
    );
  }
}
