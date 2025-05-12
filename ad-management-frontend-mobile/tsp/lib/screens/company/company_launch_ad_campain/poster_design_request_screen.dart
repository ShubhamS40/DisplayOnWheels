import 'package:flutter/material.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/components/theme_constants.dart';

class PosterDesignRequestScreen extends StatefulWidget {
  const PosterDesignRequestScreen({Key? key}) : super(key: key);

  @override
  State<PosterDesignRequestScreen> createState() => _PosterDesignRequestScreenState();
}

class _PosterDesignRequestScreenState extends State<PosterDesignRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _designIdeasController = TextEditingController();
  
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
    _notesController.addListener(_updateWordCount);
  }
  
  @override
  void dispose() {
    _notesController.removeListener(_updateWordCount);
    _titleController.dispose();
    _notesController.dispose();
    _designIdeasController.dispose();
    super.dispose();
  }
  
  void _updateWordCount() {
    final text = _notesController.text.trim();
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Request Poster Design'),
        backgroundColor: AdCampaignTheme.primaryOrange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                      'Our professional designers will create the perfect advertisement poster for your campaign.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AdCampaignTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Poster Title (Optional)
              const Text(
                'Poster Title (Optional)',
                style: AdCampaignTheme.subheadingStyle,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: AdCampaignTheme.inputDecoration(
                  '',
                  hintText: 'Poster Title (If Any)',
                ).copyWith(
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              
              // Details/Notes about Poster Design
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
                controller: _notesController,
                maxLines: 6,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                validator: (value) {
                  if (_wordCount < _requiredWordCount) {
                    return 'Please enter at least $_requiredWordCount words';
                  }
                  return null;
                },
                decoration: AdCampaignTheme.inputDecoration(
                  '',
                  hintText: 'Describe in detail what you want in your poster. Include information about your brand, target audience, key messaging, and any specific requirements.',
                ).copyWith(
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
                  errorStyle: TextStyle(
                    color: Colors.red[300],
                  ),
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
              const SizedBox(height: 20),
              
              // Design Ideas (Optional)
              const Text(
                'If you have any Design in mind (Optional)',
                style: AdCampaignTheme.subheadingStyle,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _designIdeasController,
                maxLines: 3,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: AdCampaignTheme.inputDecoration(
                  '',
                  hintText: 'Share any design ideas, references, or inspiration you have in mind',
                ).copyWith(
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              
              // Select Poster Size
              const Text(
                'Select Your Poster Size',
                style: AdCampaignTheme.subheadingStyle,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  border: Border.all(color: isDarkMode ? Colors.grey[700]! : AdCampaignTheme.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedSize,
                    icon: const Icon(Icons.arrow_drop_down, color: AdCampaignTheme.primaryOrange),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AdCampaignTheme.textPrimary, 
                      fontSize: 16
                    ),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedSize = value;
                        });
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
                            'Price',
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
              
              const SizedBox(height: 30),
              
              // Save & Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdCampaignTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _isValidWordCount) {
                      // Return poster design details to the previous screen
                      Navigator.pop(context, {
                        'posterSize': _selectedSize,
                        'posterPrice': _posterSizePrices[_selectedSize] ?? 5000.0,
                        'posterTitle': _titleController.text,
                        'posterNotes': _notesController.text,
                        'designIdeas': _designIdeasController.text,
                      });
                    }
                  },
                  child: const Text('Save & Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
