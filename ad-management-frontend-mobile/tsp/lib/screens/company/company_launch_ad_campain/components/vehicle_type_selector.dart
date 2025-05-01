import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/theme_constants.dart';

class VehicleTypeSelector extends StatefulWidget {
  final Function(String) onSelected;

  const VehicleTypeSelector({
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<VehicleTypeSelector> createState() => _VehicleTypeSelectorState();
}

class _VehicleTypeSelectorState extends State<VehicleTypeSelector> {
  String _selectedType = '';
  final List<String> _vehicleTypes = ['Hatchback', 'Sedan', 'SUV', 'Others'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Vehicle Type',
          style: AdCampaignTheme.subheadingStyle,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _vehicleTypes.map((type) {
              bool isSelected = _selectedType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  selectedColor: AdCampaignTheme.primaryOrange,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected 
                        ? AdCampaignTheme.primaryWhite
                        : AdCampaignTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? type : '';
                    });
                    widget.onSelected(_selectedType);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
