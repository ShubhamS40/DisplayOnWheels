// Mobile implementation
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

class PlatformUtils {
  static Future<Uint8List> fileToBytes(dynamic file) async {
    if (file is File) {
      return await file.readAsBytes();
    } else if (file is Uint8List) {
      return file;
    }
    
    throw Exception('Invalid file type for mobile platform');
  }

  static String getMimeType(String fileName) {
    final mimeType = lookupMimeType(fileName);
    return mimeType ?? 'application/octet-stream';
  }

  static Future<void> saveFile(String content, String filePath) async {
    final file = File(filePath);
    await file.writeAsString(content);
  }
}
