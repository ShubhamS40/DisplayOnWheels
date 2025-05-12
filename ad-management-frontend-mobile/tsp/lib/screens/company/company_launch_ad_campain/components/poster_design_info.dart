import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/theme_constants.dart';

class PosterDesignInfo extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController notesController;
  final TextEditingController designIdeasController;
  final Function(String) onPosterSizeSelected;
  final Function(double) onPosterPriceUpdated;

  const PosterDesignInfo({
    Key? key,
    required this.titleController,
    required this.notesController,
    required this.designIdeasController,
    required this.onPosterSizeSelected,
    required this.onPosterPriceUpdated,
  }) : super(key: key);

  @override
  State<PosterDesignInfo> createState() => _PosterDesignInfoState();
}

class _PosterDesignInfoState extends State<PosterDesignInfo> {
  String _selectedSize = 'A3';
  int _wordCount = 0;
  bool _isValidWordCount = false;
  final int _requiredWordCount = 300;
  
  // Poster sizes with prices
  final Map<String, double> _posterSizePrices = {
    'A2': 7500.0,
    'A3': 5000.0,
    'A4': 3500.0,
    'A5': 2500.0,
  };
  
  @override
  void initState() {
    super.initState();
    widget.notesController.addListener(_updateWordCount);
    // Initialize with A3 price
    widget.onPosterPriceUpdated(_posterSizePrices[_selectedSize] ?? 0);
  }
  
  @override
  void dispose() {
    widget.notesController.removeListener(_updateWordCount);
    super.dispose();
  }
  
  void _updateWordCount() {
    final text = widget.notesController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _wordCount = 0;
        _isValidWordCount = false;
      });
      return;
    }
    
    // Count words by splitting on whitespace
    final words = text.split(RegExp(r'\s+'));
    final nonEmptyWords = words.where((word) => word.isNotEmpty).length;
    
    setState(() {
      _wordCount = nonEmptyWords;
      _isValidWordCount = nonEmptyWords >= _requiredWordCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AdCampaignTheme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdCampaignTheme.primaryOrange.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Request a Custom Poster Design',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AdCampaignTheme.primaryOrange,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Don\'t have a poster? Our professional designers will create one for you!',
                style: TextStyle(
                  fontSize: 14,
                  color: AdCampaignTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        const Text(
          'Poster Title (Optional)',
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
          'Details/Notes about Poster Design*',
          style: AdCampaignTheme.subheadingStyle,
        ),
        const SizedBox(height: 4),
        Text(
          'Minimum $_requiredWordCount words required',
          style: TextStyle(
            fontSize: 12,
            color: _isValidWordCount ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: widget.notesController,
          maxLines: 6,
          validator: (value) {
            if (_wordCount < _requiredWordCount) {
              return 'Please enter at least $_requiredWordCount words';
            }
            return null;
          },
          decoration: AdCampaignTheme.inputDecoration(
            '',
            hintText: 'Describe in detail what you want in your poster. Include information about your brand, target audience, key messaging, and any specific requirements.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
          child: Text(
            'Word count: $_wordCount / $_requiredWordCount',
            style: TextStyle(
              fontSize: 12,
              color: _isValidWordCount ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
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
                  widget.onPosterPriceUpdated(_posterSizePrices[value] ?? 0);
                }
              },
              items: _posterSizePrices.entries.map<DropdownMenuItem<String>>((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(
                        '— Rs. ${entry.value.toStringAsFixed(0)}/-',
                        style: const TextStyle(
                          color: AdCampaignTheme.primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AdCampaignTheme.secondaryBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AdCampaignTheme.primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Selection',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AdCampaignTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Poster Size $_selectedSize — Rs. ${_posterSizePrices[_selectedSize]?.toStringAsFixed(0) ?? 0}/-',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AdCampaignTheme.primaryOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Our professional designers will create a high-quality poster based on your requirements. The design fee will be added to your total campaign cost.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
