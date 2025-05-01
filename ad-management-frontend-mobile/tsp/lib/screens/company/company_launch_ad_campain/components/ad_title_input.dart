import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/theme_constants.dart';

class AdTitleInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const AdTitleInput({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Ad Title',
            style: AdCampaignTheme.subheadingStyle,
          ),
        ),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          decoration: AdCampaignTheme.inputDecoration(
            '',
            hintText: 'Enter Ad Title',
          ),
          style: const TextStyle(
            color: AdCampaignTheme.textPrimary,
            fontSize: 16,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an ad title';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
