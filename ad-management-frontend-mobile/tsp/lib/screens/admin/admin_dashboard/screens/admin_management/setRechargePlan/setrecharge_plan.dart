import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tsp/utils/theme_constants.dart';

class AdminRechargePlansScreen extends StatefulWidget {
  @override
  _AdminRechargePlansScreenState createState() =>
      _AdminRechargePlansScreenState();
}

class _AdminRechargePlansScreenState extends State<AdminRechargePlansScreen> {
  List plans = [];
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> formData = {
    'title': '',
    'subtitle': '',
    'note': '',
    'price': '',
    'durationDays': '',
    'features': '',
    'isRecommended': false,
    'isActive': true,
    'maxVehicles': '',
  };
  int? editingId;

  final baseUrl =
      'http://localhost:5000/api/admin-manage'; // change to your backend URL

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    final res = await http.get(Uri.parse('$baseUrl/recharge'));
    if (res.statusCode == 200) {
      setState(() {
        plans = json.decode(res.body);
      });
    }
  }

  Future<void> createOrUpdatePlan() async {
    final body = {
      ...formData,
      'price': double.tryParse(formData['price']) ?? 0,
      'durationDays': int.tryParse(formData['durationDays']) ?? 0,
      'maxVehicles': int.tryParse(formData['maxVehicles']) ?? 0,
      'features': formData['features'].split(',').map((f) => f.trim()).toList(),
    };

    final url = editingId == null
        ? '$baseUrl/create-recharge-plan'
        : '$baseUrl/update-recharge-plan/$editingId';
    final res = editingId == null
        ? await http.post(Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body))
        : await http.put(Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body));

    if (res.statusCode == 201 || res.statusCode == 200) {
      fetchPlans();
      resetForm();
      Navigator.of(context).pop();
    }
  }

  Future<void> deletePlan(int id) async {
    final res =
        await http.delete(Uri.parse('$baseUrl/delete-recharge-plan/$id'));
    if (res.statusCode == 200) {
      fetchPlans();
    }
  }

  void resetForm() {
    formData = {
      'title': '',
      'subtitle': '',
      'note': '',
      'price': '',
      'durationDays': '',
      'features': '',
      'isRecommended': false,
      'isActive': true,
      'maxVehicles': '',
    };
    editingId = null;
  }

  void openPlanForm({Map? plan}) {
    final orangeColor = const Color(0xFFFF5722); // Primary orange color
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (plan != null) {
      editingId = plan['id'];
      formData = {
        'title': plan['title'],
        'subtitle': plan['subtitle'],
        'note': plan['note'] ?? '',
        'price': plan['price'].toString(),
        'durationDays': plan['durationDays'].toString(),
        'features':
            (plan['features'] as List).map((f) => f['feature']).join(', '),
        'isRecommended': plan['isRecommended'],
        'isActive': plan['isActive'],
        'maxVehicles': plan['maxVehicles']?.toString() ?? '',
      };
    } else {
      resetForm();
    }

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (context, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header bar with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      orangeColor,
                      orangeColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                width: double.infinity,
                child: Center(
                  child: Text(
                    editingId == null ? 'Create New Recharge Plan' : 'Edit Recharge Plan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Scrollable form
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Form sections
                        _buildFormSection(
                          'Plan Details',
                          [
                            _buildEnhancedTextField('Title', 'title', 
                              icon: Icons.title,
                              hint: '15 Days Plan',
                            ),
                            _buildEnhancedTextField('Subtitle', 'subtitle',
                              icon: Icons.short_text,
                              hint: 'Short-term promotion',
                            ),
                            _buildEnhancedTextField('Note (optional)', 'note',
                              icon: Icons.note,
                              hint: 'Ideal for limited-time promotions',
                              maxLines: 2,
                            ),
                          ],
                        ),
                        
                        _buildFormSection(
                          'Pricing & Duration',
                          [
                            _buildEnhancedTextField('Price (₹)', 'price',
                              icon: Icons.currency_rupee,
                              hint: '5000',
                              isNumber: true,
                            ),
                            _buildEnhancedTextField('Duration (days)', 'durationDays',
                              icon: Icons.calendar_today,
                              hint: '15',
                              isNumber: true,
                            ),
                            _buildEnhancedTextField('Max Vehicles', 'maxVehicles',
                              icon: Icons.directions_car,
                              hint: '5',
                              isNumber: true,
                            ),
                          ],
                        ),
                        
                        _buildFormSection(
                          'Features',
                          [
                            _buildEnhancedTextField('Features (comma separated)', 'features',
                              icon: Icons.featured_play_list,
                              hint: 'Basic analytics, Single location targeting',
                              maxLines: 3,
                              helperText: 'Each feature will be displayed with a check mark',
                            ),
                          ],
                        ),
                        
                        _buildFormSection(
                          'Settings',
                          [
                            // Recommended switch
                            SwitchListTile(
                              title: Row(
                                children: [
                                  Icon(Icons.star, color: orangeColor, size: 20),
                                  const SizedBox(width: 10),
                                  const Text('Recommended Plan'),
                                ],
                              ),
                              subtitle: const Text('Highlight this plan as recommended to users'),
                              value: formData['isRecommended'],
                              activeColor: orangeColor,
                              onChanged: (v) {
                                setModalState(() => formData['isRecommended'] = v);
                                setState(() => formData['isRecommended'] = v);
                              },
                            ),
                            
                            // Active switch
                            SwitchListTile(
                              title: Row(
                                children: [
                                  Icon(Icons.toggle_on, 
                                    color: formData['isActive'] ? Colors.green : Colors.grey, 
                                    size: 20
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('Active'),
                                ],
                              ),
                              subtitle: const Text('Plan will be visible to users when active'),
                              value: formData['isActive'],
                              activeColor: Colors.green,
                              onChanged: (v) {
                                setModalState(() => formData['isActive'] = v);
                                setState(() => formData['isActive'] = v);
                              },
                            ),
                          ],
                        ),
                        
                        // Buttons
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (editingId != null)
                              Expanded(
                                flex: 1,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.cancel, size: 16),
                                  label: const Text('Cancel'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: BorderSide(color: isDarkMode ? Colors.grey : Colors.grey.shade400),
                                    foregroundColor: isDarkMode ? Colors.grey : Colors.grey.shade700,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    resetForm();
                                  },
                                ),
                              ),
                            if (editingId != null) const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                icon: Icon(editingId == null ? Icons.save : Icons.update, size: 16),
                                label: Text(editingId == null ? 'Save Plan' : 'Update Plan'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: orangeColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {
                                  createOrUpdatePlan();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to build form sections with title
  Widget _buildFormSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: const Color(0xFFFF5722),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const Divider(),
        ...children,
      ],
    );
  }
  
  // Enhanced text field with icon and better styling
  Widget _buildEnhancedTextField(
    String label, 
    String field, {
    IconData? icon,
    String? hint,
    bool isNumber = false,
    int maxLines = 1,
    String? helperText,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: formData[field],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helperText,
          helperMaxLines: 2,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFFFF5722),
            ),
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        onChanged: (v) => formData[field] = v,
        validator: (value) {
          if (field == 'note') return null; // Note is optional
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(String label, String field, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        initialValue: formData[field],
        decoration: InputDecoration(labelText: label),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onChanged: (v) => formData[field] = v,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orangeColor = const Color(0xFFFF5722); // Primary orange color
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.grey[100];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Recharge Plans'),
        backgroundColor: orangeColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchPlans,
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
              'Configure and manage available recharge plans',
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
            child: plans.isEmpty
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
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      
                      // Format price for display
                      final priceString = '₹ ${plan['price']}'
                          .replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},');
                      
                      // Extract features as list
                      List<String> features = [];
                      if (plan['features'] != null) {
                        features = (plan['features'] as List)
                            .map((f) => f['feature']?.toString() ?? '')
                            .where((f) => f.isNotEmpty)
                            .toList();
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Plan header with edit/delete options
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Plan title and subtitle
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              plan['title'] ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: isDarkMode ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              plan['subtitle'] ?? '',
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
                                              '${plan['durationDays']} days',
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
                                ),
                                
                                // Recommended ribbon
                                if (plan['isRecommended'] == true)
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

                            const Divider(height: 1),

                            // Features list
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                  
                                  // Plan description/note
                                  if (plan['note'] != null && plan['note'].toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        plan['note'],
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                    
                                  // Max vehicles info
                                  if (plan['maxVehicles'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Up to ${plan['maxVehicles']} vehicles',
                                        style: TextStyle(
                                          color: orangeColor.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Actions row
                            Container(
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Active status indicator
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: plan['isActive'] == true ? Colors.green : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        plan['isActive'] == true ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: plan['isActive'] == true ? Colors.green : Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Action buttons
                                  Row(
                                    children: [
                                      TextButton.icon(
                                        icon: Icon(Icons.edit, color: orangeColor, size: 20),
                                        label: Text('Edit', style: TextStyle(color: orangeColor)),
                                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                                        onPressed: () => openPlanForm(plan: plan),
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                                        onPressed: () => _showDeleteConfirmation(plan['id'], plan['title']),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: orangeColor,
        child: const Icon(Icons.add),
        tooltip: 'Add new plan',
        onPressed: () => openPlanForm(),
      ),
    );
  }
  
  void _showDeleteConfirmation(int id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deletePlan(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
