// Platform utilities dispatcher
import 'package:flutter/foundation.dart' show kIsWeb;

// We're using conditional exports to handle the platform differences
// This is a safer approach that avoids direct dart:html imports
export 'mobile_utils.dart' if (dart.library.html) 'web_utils.dart';

// This class exists just to make it clear which implementation we're using
class PlatformUtilsInfo {
  static bool get isUsingWebImplementation => kIsWeb;
  
  // Helper method to determine if we're in a web context
  static bool get isWeb => kIsWeb;
  
  // Helper method to determine if we're in a mobile context
  static bool get isMobile => !kIsWeb;
}
