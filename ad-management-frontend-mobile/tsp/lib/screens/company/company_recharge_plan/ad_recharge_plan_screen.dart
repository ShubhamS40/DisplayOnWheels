import 'package:flutter/material.dart';
import 'package:tsp/utils/theme_constants.dart';

class AdRechargePlanScreen extends StatefulWidget {
  final bool isAdmin;
  
  const AdRechargePlanScreen({
    super.key, 
    this.isAdmin = false
  });

  @override
  State<AdRechargePlanScreen> createState() => _AdRechargePlanScreenState();
}

class _AdRechargePlanScreenState extends State<AdRechargePlanScreen> {
  int? _selectedPlanIndex;
  Map<String, dynamic>? _selectedPlanDetails;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();
  
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : ThemeConstants.textPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? 'Manage Recharge Plans' : 'Recharge Plans'),
        backgroundColor: ThemeConstants.primaryColor,
        actions: widget.isAdmin ? [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddPlanDialog(context);
            },
          ),
        ] : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.isAdmin 
                ? 'Configure and manage available recharge plans'
                : 'Choose a plan that fits your advertising needs',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                final isSelected = _selectedPlanIndex == index;
                
                return PlanCard(
                  title: plan['title'],
                  subtitle: plan['subtitle'],
                  note: plan['note'],
                  priceString: plan['priceString'],
                  duration: plan['duration'],
                  features: plan['features'],
                  isSelected: isSelected,
                  isRecommended: plan['recommended'],
                  onSelect: () {
                    setState(() {
                      _selectedPlanIndex = index;
                      _selectedPlanDetails = plan;
                    });
                  },
                  isAdmin: widget.isAdmin,
                  onEdit: widget.isAdmin ? () {
                    _showEditPlanDialog(context, plan, index);
                  } : null,
                );
              },
            ),
          ),
          if (_selectedPlanDetails != null && !widget.isAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Handle checkout logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Processing payment for ${_selectedPlanDetails!['title']}'),
                      backgroundColor: ThemeConstants.primaryColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 0),
                ),
                child: Text(
                  'Proceed to Checkout (${_selectedPlanDetails!['priceString']})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  void _showAddPlanDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String subtitle = '';
    String note = '';
    String price = '';
    String duration = '';
    String features = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Recharge Plan'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title (e.g. "15 Days Plan")'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => title = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Subtitle'),
                  onSaved: (value) => subtitle = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Note'),
                  onSaved: (value) => note = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Price (e.g. "Rs 5,000")'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => price = value!,
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Duration (e.g. "15 days")'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => duration = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Features (comma separated)'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => features = value!,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                // Add new plan logic here
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('New plan added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primaryColor,
            ),
            child: Text('Add Plan'),
          ),
        ],
      ),
    );
  }
  
  void _showEditPlanDialog(BuildContext context, Map<String, dynamic> plan, int index) {
    final formKey = GlobalKey<FormState>();
    _priceController.text = plan['priceString'].toString().replaceAll('Rs ', '');
    _featuresController.text = plan['features'].join(', ');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${plan['title']}'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: plan['title'],
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: plan['subtitle'],
                  decoration: InputDecoration(labelText: 'Subtitle'),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price (in Rs)'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  initialValue: plan['duration'],
                  decoration: InputDecoration(labelText: 'Duration'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: _featuresController,
                  decoration: InputDecoration(
                    labelText: 'Features',
                    helperText: 'Separate features with commas',
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  maxLines: 3,
                ),
                SwitchListTile(
                  title: Text('Recommended Plan'),
                  value: plan['recommended'] ?? false,
                  onChanged: (value) {
                    // Implementation would set this value
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Update plan logic here
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Plan updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primaryColor,
            ),
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _priceController.dispose();
    _featuresController.dispose();
    super.dispose();
  }
}

class PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String note;
  final String priceString;
  final String duration;
  final List<dynamic> features;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onSelect;
  final bool isAdmin;
  final VoidCallback? onEdit;

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
    this.isAdmin = false,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : ThemeConstants.textPrimary;
    final orangeColor = const Color(0xFFFF5722); // Primary orange color

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
              ...List.generate(
                features.length,
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
                        features[index],
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
              if (isAdmin)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: onEdit,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
