import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'driver_upload_status_screen.dart';
import 'driver_main_screen.dart';

class DriverUploadAdvertisementProof extends StatefulWidget {
  const DriverUploadAdvertisementProof({Key? key}) : super(key: key);

  @override
  State<DriverUploadAdvertisementProof> createState() =>
      _DriverUploadAdvertisementProofState();
}

class _DriverUploadAdvertisementProofState
    extends State<DriverUploadAdvertisementProof> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  static const Color primaryOrange = Color(0xFFFF7F00);

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _uploadImage() {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Simulate upload delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isUploading = false;
      });

      // Navigate to status screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DriverUploadStatusScreen(
            status: 'Pending', // Initial status is pending
          ),
        ),
      );
    });
  }

  // Method to check advertisement status and navigate appropriately
  void checkAdvertisementStatus(BuildContext context) {
    // This would typically involve an API call to check the status
    // For demonstration, we'll use a simulated status

    // Simulate network delay
    setState(() {
      _isUploading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isUploading = false;
      });

      // Get status (this would come from your backend)
      final String status =
          'Pending'; // Could be 'Approved', 'Rejected', or 'Pending'

      if (status == 'Approved') {
        // If already approved, go directly to main screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const DriverMainScreen(),
          ),
          (route) => false,
        );
      } else {
        // Otherwise go to status screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverUploadStatusScreen(status: status),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Advertisement Proof'),
        backgroundColor: primaryOrange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection(),
              const SizedBox(height: 20),
              _buildImageSection(),
              const SizedBox(height: 30),
              _buildUploadButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Advertisement Proof Guidelines',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '1. Make sure the entire advertisement is visible in the photo',
            style: TextStyle(height: 1.4),
          ),
          Text(
            '2. Ensure the photo is clear and well-lit',
            style: TextStyle(height: 1.4),
          ),
          Text(
            '3. Take the photo from a distance that shows the ad on your vehicle',
            style: TextStyle(height: 1.4),
          ),
          Text(
            '4. Include your license plate in the photo (if possible)',
            style: TextStyle(height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Photo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        _image == null ? _buildImagePlaceholder() : _buildSelectedImage(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _getImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _getImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryOrange,
                  side: BorderSide(color: primaryOrange),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            'No image selected',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImage() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: FileImage(_image!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: InkWell(
            onTap: () {
              setState(() {
                _image = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.red, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _image == null || _isUploading ? null : _uploadImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          disabledBackgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isUploading
            ? const SizedBox(
                height: 24,
                width: 24,
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
                ),
              ),
      ),
    );
  }
}
