import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/theme_constants.dart';

class PosterUploadSection extends StatefulWidget {
  final Function(File?) onPosterSelected;
  final Function(Uint8List?) onWebPosterSelected;

  const PosterUploadSection({
    Key? key,
    required this.onPosterSelected,
    required this.onWebPosterSelected,
  }) : super(key: key);

  @override
  State<PosterUploadSection> createState() => _PosterUploadSectionState();
}

class _PosterUploadSectionState extends State<PosterUploadSection> {
  File? _selectedFile;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Advertisement Poster',
          style: AdCampaignTheme.subheadingStyle,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AdCampaignTheme.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _getFileName() ?? 'Advertisement Poster',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdCampaignTheme.textSecondary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.upload_file,
                  color: AdCampaignTheme.primaryOrange,
                ),
                onPressed: _pickImage,
              ),
            ],
          ),
        ),
        if (_hasSelectedImage())
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AdCampaignTheme.borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildImagePreview(),
          ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: const Text(
            'If you don\'t have a poster yet, don\'t worry! Fill out this form, and our designer will create the perfect advertisement poster for your product.',
            style: TextStyle(
              fontSize: 14,
              color: AdCampaignTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // For web
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
          });
          widget.onWebPosterSelected(bytes);
        } else {
          // For mobile
          setState(() {
            _selectedFile = File(pickedFile.path);
          });
          widget.onPosterSelected(_selectedFile);
        }
      }
    } catch (e) {
      // Handle error
      debugPrint('Error picking image: $e');
    }
  }

  String? _getFileName() {
    if (_selectedFile != null) {
      return _selectedFile!.path.split('/').last;
    } else if (_webImage != null) {
      return 'Selected Poster';
    }
    return null;
  }

  bool _hasSelectedImage() {
    return _selectedFile != null || _webImage != null;
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _webImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          _webImage!,
          fit: BoxFit.cover,
        ),
      );
    } else if (_selectedFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _selectedFile!,
          fit: BoxFit.cover,
        ),
      );
    }
    return const Center(
      child: Text('No image selected'),
    );
  }
}
