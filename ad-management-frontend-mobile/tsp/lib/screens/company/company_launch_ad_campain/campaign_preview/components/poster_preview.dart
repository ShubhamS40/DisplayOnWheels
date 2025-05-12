import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PosterPreview extends StatelessWidget {
  final dynamic fileInput;
  final dynamic bytesInput;
  final BoxFit fit;

  const PosterPreview({
    Key? key,
    this.fileInput,
    this.bytesInput,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safe type conversion for bytes
    Uint8List? bytes;
    if (bytesInput != null) {
      if (bytesInput is Uint8List) {
        bytes = bytesInput;
      } else {
        try {
          // Try to convert if it's something else
          if (bytesInput is List<int>) {
            bytes = Uint8List.fromList(bytesInput);
          }
        } catch (e) {
          debugPrint('Error converting bytes: $e');
        }
      }
    }
    
    // Safe type conversion for file
    File? file;
    if (fileInput != null) {
      if (fileInput is File) {
        file = fileInput;
      } else if (fileInput is String) {
        try {
          // Try to convert if it's a file path
          file = File(fileInput);
        } catch (e) {
          debugPrint('Error converting file path: $e');
        }
      }
    }
    
    if (bytes != null) {
      return Image.memory(bytes, fit: fit);
    } else if (file != null && file.existsSync()) {
      return Image.file(file, fit: fit);
    } else {
      return const Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey,
          size: 48,
        ),
      );
    }
  }
}

class PosterPreviewDialog extends StatelessWidget {
  final Map<String, dynamic> campaignDetails;
  final bool isDarkMode;
  final Color orangeColor;

  const PosterPreviewDialog({
    Key? key,
    required this.campaignDetails,
    required this.isDarkMode,
    required this.orangeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  campaignDetails['posterTitle'] ?? 'Campaign Poster',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Poster preview
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: PosterPreview(
                fileInput: campaignDetails['posterFile'],
                bytesInput: campaignDetails['posterBytes'],
              ),
            ),
          ),
          
          // Footer with poster size and download button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Size: ${campaignDetails['posterSize'] ?? 'A3'}',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                ),
                TextButton.icon(
                  icon: Icon(
                    Icons.download,
                    color: orangeColor,
                  ),
                  label: Text(
                    'Save',
                    style: TextStyle(
                      color: orangeColor,
                    ),
                  ),
                  onPressed: () {
                    // Download functionality would go here
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Poster saved to gallery'),
                        backgroundColor: isDarkMode ? Colors.grey[800] : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
