import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that prevents users from navigating back to login screens
/// after successful authentication by intercepting back button presses.
class AuthProtectedScreen extends StatelessWidget {
  final Widget child;
  final bool canPop;
  final VoidCallback? onPopInvoked;

  /// Creates an auth protected screen
  /// - [child]: The screen content to display
  /// - [canPop]: Whether the back button should allow popping (defaults to false for auth screens)
  /// - [onPopInvoked]: Optional callback when back is pressed (can be used for custom behavior like showing exit dialog)
  const AuthProtectedScreen({
    Key? key,
    required this.child,
    this.canPop = false,
    this.onPopInvoked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (didPop) return;
        
        if (onPopInvoked != null) {
          onPopInvoked!();
        } else {
          // Default behavior: Show dialog to confirm app exit
          _showExitConfirmationDialog(context);
        }
      },
      child: child,
    );
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App?'),
        content: const Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
