import 'package:flutter/material.dart';

class RechargePlanScreen extends StatefulWidget {
  const RechargePlanScreen({super.key});

  @override
  State<RechargePlanScreen> createState() => _RechargePlanScreenState();
}

class _RechargePlanScreenState extends State<RechargePlanScreen> {
  int? _selectedPlanIndex;
  Map<String, dynamic>? _selectedPlanDetails;
  
  // Enhanced plan data with more details
  final List<Map<String, dynamic>> plans = const [
    {
      'title': '15 Days Plan',
      'subtitle': 'Short-term promotion',
      'note': 'Ideal for limited-time promotions',
      'price': 5000,
      'priceString': 'Rs 5,000',
      'duration': '15 days',
      'features': ['Basic analytics', 'Single location targeting', 'Up to 5 vehicles'],
      'recommended': false,
    },
    {
      'title': '28 Days Plan',
      'subtitle': 'Most popular',
      'note': 'Perfect for monthly campaigns',
      'price': 9000,
      'priceString': 'Rs 9,000',
      'duration': '28 days',
      'features': ['Detailed analytics', 'Multi-location targeting', 'Up to 10 vehicles'],
      'recommended': true,
    },
    {
      'title': '84 Days Plan',
      'subtitle': 'Seasonal promotion',
      'note': 'Great value for longer campaigns',
      'price': 25000,
      'priceString': 'Rs 25,000',
      'duration': '84 days',
      'features': ['Advanced analytics', 'City-wide targeting', 'Up to 20 vehicles', 'Priority support'],
      'recommended': false,
    },
    {
      'title': 'Yearly Plan',
      'subtitle': 'Best value',
      'note': 'Ultimate ad experience for big brands',
      'price': 90000,
      'priceString': 'Rs 90,000',
      'duration': '365 days',
      'features': ['Premium analytics', 'National targeting', 'Unlimited vehicles', 'Premium support', 'Custom branding'],
      'recommended': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final orangeColor = const Color(0xFFFF5722); // Primary orange color
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Ad Plan'),
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Container(
        color: isDarkMode ? Colors.black : Colors.white,
        child: Column(
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              width: double.infinity,
              color: isDarkMode 
                ? Colors.black 
                : orangeColor.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Ad Campaign Plan',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select the perfect plan that fits your advertising needs',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            
            // Plans section
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final isSelected = _selectedPlanIndex == index;
                  
                  return PlanCard(
                    plan: plan,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedPlanIndex = index;
                        _selectedPlanDetails = {
                          'planName': plan['title'],
                          'price': plan['price'],
                          'duration': plan['duration'],
                          'features': plan['features'],
                        };
                      });
                    },
                    isDarkMode: isDarkMode,
                    orangeColor: orangeColor,
                  );
                },
              ),
            ),
            
            // Bottom action bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Selected plan info
                  Expanded(
                    child: _selectedPlanIndex != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plans[_selectedPlanIndex!]['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                plans[_selectedPlanIndex!]['priceString'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: orangeColor,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Select a plan to continue',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white54 : Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                  
                  // Continue button
                  ElevatedButton(
                    onPressed: _selectedPlanIndex != null
                        ? () {
                            Navigator.pop(context, _selectedPlanDetails);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;
  final Color orangeColor;

  const PlanCard({
    Key? key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.isDarkMode,
    required this.orangeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? orangeColor
                  : isDarkMode ? Colors.grey[800]! : Colors.grey.withOpacity(0.2),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan['subtitle'],
                            style: TextStyle(
                              color: orangeColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
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
                              plan['priceString'],
                              style: TextStyle(
                                color: orangeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              plan['duration'],
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
                  if (plan['recommended'])
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
              ...List.generate(
                plan['features'].length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: orangeColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        plan['features'][index],
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Plan description
              Text(
                plan['note'],
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
                        color: orangeColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Selected',
                        style: TextStyle(
                          color: orangeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
