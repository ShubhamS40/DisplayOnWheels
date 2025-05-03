import 'package:flutter/material.dart';
import '../../../../utils/theme_constants.dart';

class DriverAssignmentList extends StatelessWidget {
  final List<DriverAssignment> drivers;
  final Function(DriverAssignment)? onDriverTap;

  const DriverAssignmentList({
    Key? key,
    required this.drivers,
    this.onDriverTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : ThemeConstants.textPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: ThemeConstants.getCardDecoration(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Driver Ad Assignment',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.people_alt_outlined,
                color: ThemeConstants.primaryColor,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Driver list
          ...drivers.map((driver) => _buildDriverItem(driver, context)).toList(),
        ],
      ),
    );
  }

  Widget _buildDriverItem(DriverAssignment driver, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : ThemeConstants.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (onDriverTap != null) {
              onDriverTap!(driver);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                // Driver avatar or icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ThemeConstants.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    driver.isActive ? Icons.emoji_people : Icons.person_outline,
                    color: ThemeConstants.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Driver info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Company ${driver.companyName}',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Search action button
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: ThemeConstants.primaryColor,
                    size: 20,
                  ),
                  onPressed: () {
                    if (onDriverTap != null) {
                      onDriverTap!(driver);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DriverAssignment {
  final String id;
  final String name;
  final String companyName;
  final bool isActive;

  DriverAssignment({
    required this.id,
    required this.name,
    required this.companyName,
    this.isActive = true,
  });
}
