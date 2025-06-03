import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/theme_constants.dart';
import 'package:tsp/screens/company/company_recharge_plan/ad_recharge_plan_screen.dart';

// Your existing provider
final rechargePlanIdProvider = StateProvider<String?>((ref) => null);

class PlanSelectorButton extends ConsumerWidget {
  final String? selectedPlan;
  final Function(String, int, Map<String, dynamic>?) onPlanSelected;

  // Enhanced constructor to handle detailed plan data
  const PlanSelectorButton({
    Key? key,
    this.selectedPlan,
    required this.onPlanSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get current selected plan ID
    final selectedPlanId = ref.watch(rechargePlanIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Plan That\'s Fit for you',
          style: AdCampaignTheme.subheadingStyle,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 50,
          margin: const EdgeInsets.only(bottom: 20),
          child: ElevatedButton(
            style: AdCampaignTheme.primaryButtonStyle,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdRechargePlanScreen(),
                ),
              );

              if (result != null && result is Map<String, dynamic>) {
                // Set the planId in the provider state
                final planId =
                    result['planId']?.toString() ?? result['id']?.toString();
                if (planId != null) {
                  ref.read(rechargePlanIdProvider.notifier).state = planId;
                }

                // Process the selected plan data with detailed plan information
                onPlanSelected(
                  result['planName'] ?? '',
                  result['price'] ?? 0,
                  result['planDetails'],
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.schedule, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  selectedPlan != null && selectedPlan!.isNotEmpty
                      ? selectedPlan!
                      : selectedPlanId != null
                          ? 'Plan ID: $selectedPlanId Selected'
                          : 'Choose Your Plan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
