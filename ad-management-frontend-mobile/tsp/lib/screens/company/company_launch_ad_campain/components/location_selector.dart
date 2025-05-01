import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/theme_constants.dart';

class LocationSelector extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onLocationSelected;

  const LocationSelector({
    Key? key,
    required this.controller,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Location',
          style: AdCampaignTheme.subheadingStyle,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: widget.controller,
          decoration: AdCampaignTheme.inputDecoration(
            '',
            hintText: 'Search Your Target Location',
            suffixIcon: const Icon(
              Icons.location_on_outlined,
              color: AdCampaignTheme.primaryOrange,
            ),
          ),
          onChanged: widget.onLocationSelected,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey,
                  size: 36,
                ),
                SizedBox(height: 8),
                Text(
                  'Target Location',
                  style: TextStyle(
                    color: AdCampaignTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
