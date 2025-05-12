import 'package:flutter/material.dart';
import 'package:tsp/services/admin/admin_campaign_service.dart';

class DriverAssignment extends StatefulWidget {
  final Map<String, dynamic> campaign;
  final Function() onAssignmentComplete;
  
  const DriverAssignment({
    Key? key,
    required this.campaign,
    required this.onAssignmentComplete,
  }) : super(key: key);

  @override
  State<DriverAssignment> createState() => _DriverAssignmentState();
}

class _DriverAssignmentState extends State<DriverAssignment> {
  final AdminCampaignService _adminCampaignService = AdminCampaignService();
  List<dynamic> _availableDrivers = [];
  List<String> _selectedDriverIds = [];
  bool _isLoading = true;
  bool _isAssigning = false;
  String? _errorMessage;
  String? _successMessage;
  
  @override
  void initState() {
    super.initState();
    _fetchAvailableDrivers();
  }
  
  Future<void> _fetchAvailableDrivers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final drivers = await _adminCampaignService.getAvailableDrivers();
    
    if (mounted) {
      setState(() {
        _availableDrivers = drivers;
        _isLoading = false;
      });
    }
  }
  
  Future<void> _assignDrivers() async {
    if (_selectedDriverIds.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one driver to assign';
      });
      return;
    }
    
    setState(() {
      _isAssigning = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    final result = await _adminCampaignService.assignDriversToCampaign(
      widget.campaign['id'],
      _selectedDriverIds,
    );
    
    if (mounted) {
      setState(() {
        _isAssigning = false;
        
        if (result['success']) {
          _successMessage = 'Drivers assigned successfully';
          _selectedDriverIds = [];
          
          // Wait a moment before triggering the callback
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              widget.onAssignmentComplete();
            }
          });
        } else {
          _errorMessage = result['message'];
        }
      });
    }
  }
  
  void _toggleDriverSelection(String driverId) {
    setState(() {
      if (_selectedDriverIds.contains(driverId)) {
        _selectedDriverIds.remove(driverId);
      } else {
        _selectedDriverIds.add(driverId);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isApproved = widget.campaign['approvalStatus'] == 'APPROVED';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign Drivers to Campaign',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF5722),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Campaign: ${widget.campaign['title']}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Location: ${widget.campaign['targetLocation']}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Vehicle Count Needed: ${widget.campaign['vehicleCount']}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Status message
        if (!isApproved)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Campaign must be approved before drivers can be assigned',
                    style: TextStyle(color: Colors.orange[800]),
                  ),
                ),
              ],
            ),
          ),
          
        if (_errorMessage != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          
        if (_successMessage != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          
        // Driver Selection
        Expanded(
          child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
            : _availableDrivers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.drive_eta_rounded, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No drivers available',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      TextButton(
                        onPressed: _fetchAvailableDrivers,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _availableDrivers.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemBuilder: (context, index) {
                    final driver = _availableDrivers[index];
                    final driverId = driver['id'];
                    final isSelected = _selectedDriverIds.contains(driverId);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      elevation: 1.0,
                      color: Colors.grey[900], // Dark background for dark mode
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFFFF5722) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        onTap: isApproved ? () => _toggleDriverSelection(driverId) : null,
                        borderRadius: BorderRadius.circular(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Driver profile image
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: driver['profileImage'] != null
                                    ? NetworkImage(driver['profileImage'])
                                    : null,
                                child: driver['profileImage'] == null
                                    ? const Icon(Icons.person, color: Colors.grey)
                                    : null,
                              ),
                              const SizedBox(width: 12.0),
                              
                              // Driver details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${driver['firstName'] ?? ''} ${driver['lastName'] ?? ''}'.trim(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF5722),
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: Text(
                                            'ID: ${driver['id'] ?? 'Unknown'}',
                                            style: const TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Icon(Icons.directions_car, size: 16.0, color: Colors.white70),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          'Type: ',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${driver['vehicleType'] ?? 'Unknown'}',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4.0),
                                    Row(
                                      children: [
                                        Icon(Icons.pin, size: 16.0, color: Colors.white70),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          'Number: ',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${driver['vehicleNumber'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Selection checkbox
                              Checkbox(
                                value: isSelected,
                                onChanged: isApproved
                                    ? (value) => _toggleDriverSelection(driverId)
                                    : null,
                                activeColor: const Color(0xFFFF5722),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        
        // Action buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                '${_selectedDriverIds.length} driver(s) selected',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _selectedDriverIds.isNotEmpty
                      ? const Color(0xFFFF5722)
                      : Colors.grey,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: (isApproved && !_isAssigning && _selectedDriverIds.isNotEmpty)
                    ? _assignDrivers
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  disabledBackgroundColor: Colors.grey[700],
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _isAssigning
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Assigning Drivers...'),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.assignment_ind, size: 18),
                          SizedBox(width: 8),
                          Text('Assign Selected Drivers'),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
