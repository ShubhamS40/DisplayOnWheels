import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tsp/utils/theme_constants.dart';

class AdRechargePlanScreen extends StatefulWidget {
  final bool isAdmin;

  const AdRechargePlanScreen({super.key, this.isAdmin = false});

  @override
  State<AdRechargePlanScreen> createState() => _AdRechargePlanScreenState();
}

class _AdRechargePlanScreenState extends State<AdRechargePlanScreen> {
  int? _selectedPlanIndex;
  Map<String, dynamic>? _selectedPlan;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _plans = [];
  
  // API endpoint
  final String baseUrl = 'http://localhost:5000/api/admin-manage';
  
  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }
  
  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/recharge'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _plans = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load plans: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load plans: $e';
        _isLoading = false;
      });
    }
  }
  
  // Default plans to use when API fails
  final List<Map<String, dynamic>> _defaultPlans = const [
    {
      'title': '15 Days Plan',
      'subtitle': 'Short-term promotion',
      'note': 'Ideal for limited-time promotions',
      'price': 5000,
      'priceString': 'Rs 5,000',
      'duration': '15 days',
      'features': [
        'Basic analytics',
        'Single location targeting',
        'Up to 5 vehicles'
      ],
      'recommended': false,
    },
    {
      'title': '28 Days Plan',
      'subtitle': 'Most popular',
      'note': 'Perfect for monthly campaigns',
      'price': 9000,
      'priceString': 'Rs 9,000',
      'duration': '28 days',
      'features': [
        'Detailed analytics',
        'Multi-location targeting',
        'Up to 10 vehicles'
      ],
      'recommended': true,
    },
    {
      'title': '84 Days Plan',
      'subtitle': 'Seasonal promotion',
      'note': 'Great value for longer campaigns',
      'price': 25000,
      'priceString': 'Rs 25,000',
      'duration': '84 days',
      'features': [
        'Advanced analytics',
        'City-wide targeting',
        'Up to 20 vehicles',
        'Priority support'
      ],
      'recommended': false,
    },
    {
      'title': 'Yearly Plan',
      'subtitle': 'Best value',
      'note': 'Ultimate ad experience for big brands',
      'price': 90000,
      'priceString': 'Rs 90,000',
      'duration': '365 days',
      'features': [
        'Premium analytics',
        'National targeting',
        'Unlimited vehicles',
        'Premium support',
        'Custom branding'
      ],
      'recommended': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final orangeColor = const Color(0xFFFF5722); // Primary orange color from the memory
    final backgroundColor = isDarkMode ? Colors.black : Colors.grey[100];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Recharge Plans'),
        backgroundColor: orangeColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPlans,
            tooltip: 'Refresh plans',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header section with description
          Container(
            width: double.infinity,
            color: isDarkMode ? Colors.black : orangeColor,
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Choose a plan that fits your advertising needs',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Plans list
          Expanded(
            child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: orangeColor),
                      const SizedBox(height: 16),
                      const Text('Loading plans...'),
                    ],
                  ),
                )
              : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchPlans,
                          style: ElevatedButton.styleFrom(backgroundColor: orangeColor),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                        const SizedBox(height: 16),
                        Text('Showing default plans', style: TextStyle(fontStyle: FontStyle.italic, color: isDarkMode ? Colors.white70 : Colors.black54)),
                        // Show default plans if API fails
                        Expanded(
                          child: _buildPlansList(_defaultPlans),
                        ),
                      ],
                    ),
                  )
                : _plans.isEmpty
                  ? Center(child: Text('No recharge plans available', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)))
                  : _buildPlansList(_plans),
          ),
          
          // Checkout button
          if (_selectedPlan != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Return only essential plan information without vehicle limits
                  Navigator.pop(context, {
                    'planName': _selectedPlan!['title'],
                    'price': _selectedPlan!['price'],
                    'duration': '${_selectedPlan!['durationDays']} days',
                    // Only passing essential plan info - name, price, and duration
                    'planDetails': {
                      'title': _selectedPlan!['title'],
                      'price': _selectedPlan!['price'],
                      'durationDays': _selectedPlan!['durationDays'],
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: Text(
                  'Select Plan (₹ ${_selectedPlan!['price']})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Helper method to build the plans list
  Widget _buildPlansList(List<Map<String, dynamic>> plans) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final isSelected = _selectedPlanIndex == index;
        
        // Format price for display
        final priceString = 'Rs ${plan['price']}'
            .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},');
        
        // Extract features
        List<String> features = [];
        if (plan['features'] != null) {
          if (plan['features'] is List) {
            features = (plan['features'] as List)
                .map((f) => f is Map ? (f['feature']?.toString() ?? '') : f.toString())
                .where((f) => f.isNotEmpty)
                .toList();
          } else if (plan['features'] is String) {
            features = [plan['features']];
          }
        }
        
        return PlanCard(
          title: plan['title'] ?? '',
          subtitle: plan['subtitle'] ?? '',
          note: plan['note'] ?? '',
          priceString: priceString,
          duration: '${plan['durationDays']} days',
          features: features,
          isSelected: isSelected,
          isRecommended: plan['isRecommended'] ?? false,
          onSelect: () {
            setState(() {
              _selectedPlanIndex = index;
              _selectedPlan = plan;
            });
          },
        );
      },
    );
  }
}

class PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String note;
  final String priceString;
  final String duration;
  final List<String> features;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onSelect;

  const PlanCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.note,
    required this.priceString,
    required this.duration,
    required this.features,
    required this.isSelected,
    required this.isRecommended,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final orangeColor = const Color(0xFFFF5722); // Primary orange color from the memory

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? orangeColor
                  : isDarkMode
                      ? Colors.grey[800]!
                      : Colors.grey.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: orangeColor.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan header with ribbon for recommended plan
              Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Plan title and subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: orangeColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Price tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: orangeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              priceString,
                              style: TextStyle(
                                color: orangeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              duration,
                              style: TextStyle(
                                color: orangeColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Recommended ribbon
                  if (isRecommended)
                    Positioned(
                      top: -5,
                      right: -5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: orangeColor,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'RECOMMENDED',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Plan features
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: orangeColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

              if (note.isNotEmpty) const SizedBox(height: 8),

              // Plan description
              if (note.isNotEmpty)
                Text(
                  note,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),

              // Selection indicator
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: orangeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: orangeColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: orangeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Selected',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: orangeColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
