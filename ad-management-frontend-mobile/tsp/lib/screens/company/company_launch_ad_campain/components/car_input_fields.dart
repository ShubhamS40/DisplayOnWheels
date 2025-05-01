import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/theme_constants.dart';

class CarInputFields extends StatelessWidget {
  final TextEditingController carCountController;
  final Function(int) onCarCountChanged;
  final int? selectedPlanPrice;

  const CarInputFields({
    Key? key,
    required this.carCountController,
    required this.onCarCountChanged,
    this.selectedPlanPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter No of Cars',
          style: AdCampaignTheme.subheadingStyle,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: carCountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: AdCampaignTheme.inputDecoration(
            '',
            hintText: 'Enter the no of cars',
          ),
          onChanged: (value) {
            int? count = int.tryParse(value);
            if (count != null) {
              onCarCountChanged(count);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter number of cars';
            }
            if (int.tryParse(value) == null || int.parse(value) <= 0) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
        const Text(
          'Total Amount',
          style: AdCampaignTheme.subheadingStyle,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AdCampaignTheme.borderColor),
            borderRadius: BorderRadius.circular(8),
            color: AdCampaignTheme.secondaryBackground,
          ),
          width: double.infinity,
          child: Text(
            calculateTotalAmount(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AdCampaignTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String calculateTotalAmount() {
    if (selectedPlanPrice == null || carCountController.text.isEmpty) {
      return 'Total No of Cars * Select plan';
    }
    
    int? carCount = int.tryParse(carCountController.text);
    if (carCount == null) {
      return 'Total No of Cars * Select plan';
    }
    
    int totalAmount = carCount * selectedPlanPrice!;
    return '₹ $totalAmount';
  }
}
