import 'package:flutter/material.dart';
import '../../../../utils/theme_constants.dart';

class ActionButtons extends StatelessWidget {
  final List<ActionButtonData> actions;

  const ActionButtons({
    Key? key,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: actions.map((action) => _buildActionButton(action, context)).toList(),
    );
  }

  Widget _buildActionButton(ActionButtonData action, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: isDarkMode ? ThemeConstants.darkCardColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: ThemeConstants.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      action.title,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ActionButtonData {
  final String title;
  final VoidCallback onTap;
  final IconData? icon;

  ActionButtonData({
    required this.title,
    required this.onTap,
    this.icon,
  });
}
