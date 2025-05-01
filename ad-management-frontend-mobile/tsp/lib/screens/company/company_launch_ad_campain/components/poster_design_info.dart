import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/theme_constants.dart';

class PosterDesignInfo extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController notesController;
  final Function(String) onPosterSizeSelected;

  const PosterDesignInfo({
    Key? key,
    required this.titleController,
    required this.notesController,
    required this.onPosterSizeSelected,
  }) : super(key: key);

  @override
  State<PosterDesignInfo> createState() => _PosterDesignInfoState();
}

class _PosterDesignInfoState extends State<PosterDesignInfo> {
  String _selectedSize = 'A3';
  final List<String> _posterSizes = ['A3', 'A4', 'A5'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Poster Title',
          style: AdCampaignTheme.subheadingStyle,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: widget.titleController,
          decoration: AdCampaignTheme.inputDecoration(
            '',
            hintText: 'Poster Title (If Any)',
          ),
        ),
        const SizedBox(height: 20),
        
        const Text(
          'Poster Design Notes',
          style: AdCampaignTheme.subheadingStyle,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: widget.notesController,
          maxLines: 5,
          maxLength: 300,
          decoration: AdCampaignTheme.inputDecoration(
            '',
            hintText: 'Details/Notes About Your Poster Design. You can explain here in this box. Our designer design poster for your advertisement product.',
          ),
        ),
        const SizedBox(height: 10),
        
        const Text(
          'Select Your Poster Size',
          style: AdCampaignTheme.subheadingStyle,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AdCampaignTheme.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedSize,
              icon: const Icon(Icons.arrow_drop_down, color: AdCampaignTheme.primaryOrange),
              style: const TextStyle(color: AdCampaignTheme.textPrimary, fontSize: 16),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedSize = value;
                  });
                  widget.onPosterSizeSelected(value);
                }
              },
              items: _posterSizes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
        
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.info_outline, color: AdCampaignTheme.primaryOrange, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Our designers will create a beautiful poster based on your inputs',
                style: TextStyle(
                  fontSize: 12,
                  color: AdCampaignTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
