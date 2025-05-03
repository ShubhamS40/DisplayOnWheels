import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_recharge_plan/ad_recharge_plan_screen.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final Map<String, dynamic> subscriptionData;
  final bool isDarkMode;

  const SubscriptionPlanCard({
    Key? key,
    required this.subscriptionData,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final orangeColor = const Color(0xFFFF5722);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company Subscription Plan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 3,
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Plan
                Row(
                  children: [
                    Icon(Icons.workspace_premium, color: orangeColor),
                    const SizedBox(width: 12),
                    Text(
                      'Current Plan',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      subscriptionData['currentPlan'],
                      style: TextStyle(
                        fontSize: 16,
                        color: orangeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Plan Expiry & Days Left
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: orangeColor),
                    const SizedBox(width: 12),
                    Text(
                      'Plan Expiry Date & Days Left',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${subscriptionData['expiryDate']}\n(${subscriptionData['daysLeft']} days left)',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Upgrade button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdRechargePlanScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Upgrade Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
