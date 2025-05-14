import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tsp/services/admin/admin_campaign_service.dart';

class CampaignDetail extends StatefulWidget {
  final Map<String, dynamic> campaign;
  final Function() onActionComplete;
  
  const CampaignDetail({
    Key? key,
    required this.campaign,
    required this.onActionComplete,
  }) : super(key: key);

  @override
  State<CampaignDetail> createState() => _CampaignDetailState();
}

class _CampaignDetailState extends State<CampaignDetail> {
  final AdminCampaignService _adminCampaignService = AdminCampaignService();
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _errorMessage;
  String? _successMessage;
  
  // Date fields
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Rejection reason
  final TextEditingController _rejectionReasonController = TextEditingController();
  
  // Deletion confirmation
  final TextEditingController _deleteConfirmController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _initDates();
  }
  
  void _initDates() {
    // Initialize with existing dates if available
    if (widget.campaign['startDate'] != null) {
      try {
        _startDate = DateTime.parse(widget.campaign['startDate']);
      } catch (_) {}
    }
    
    if (widget.campaign['endDate'] != null) {
      try {
        _endDate = DateTime.parse(widget.campaign['endDate']);
      } catch (_) {}
    }
  }
  
  Future<void> _approveCampaign() async {
    if (_startDate == null || _endDate == null) {
      setState(() {
        _errorMessage = 'Please set both start and end dates before approving';
      });
      return;
    }
    
    if (_endDate!.isBefore(_startDate!)) {
      setState(() {
        _errorMessage = 'End date cannot be before start date';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    // First update the dates
    final updateResult = await _adminCampaignService.updateCampaignDetails(
      widget.campaign['id'],
      {
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
      },
    );
    
    if (!updateResult['success']) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to update dates: ${updateResult['message']}';
        });
      }
      return;
    }
    
    // Then approve the campaign
    final result = await _adminCampaignService.approveCampaign(widget.campaign['id']);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        
        if (result['success']) {
          _successMessage = 'Campaign approved successfully';
          // Wait a moment before triggering the callback
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              widget.onActionComplete();
            }
          });
        } else {
          _errorMessage = result['message'];
        }
      });
    }
  }
  
  Future<void> _deleteCampaign() async {
    // First set the deleting state
    setState(() {
      _isDeleting = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    try {
      // Call the delete API
      final result = await _adminCampaignService.deleteCampaign(
        widget.campaign['id'],
      );
      
      if (mounted) {
        setState(() {
          _isDeleting = false;
          
          if (result['success']) {
            _successMessage = 'Campaign deleted successfully';
            // Wait a moment before triggering the callback
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                widget.onActionComplete();
              }
            });
          } else {
            _errorMessage = result['message'];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
          _errorMessage = 'An error occurred: $e';
        });
      }
    }
  }
  
  void _showDeleteConfirmation() {
    // Reset the confirmation field
    _deleteConfirmController.text = '';
    
    // Show a dialog to confirm deletion
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Campaign?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. The campaign will be permanently deleted.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            const Text('Type "DELETE" to confirm:'),
            const SizedBox(height: 8),
            TextField(
              controller: _deleteConfirmController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'DELETE',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_deleteConfirmController.text == 'DELETE') {
                Navigator.pop(context);
                _deleteCampaign();
              } else {
                // Show error that confirmation text is incorrect
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please type "DELETE" to confirm'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectCampaign() async {
    if (_rejectionReasonController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please provide a reason for rejection';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    final result = await _adminCampaignService.rejectCampaign(
      widget.campaign['id'], 
      _rejectionReasonController.text.trim(),
    );
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        
        if (result['success']) {
          _successMessage = 'Campaign rejected successfully';
          // Wait a moment before triggering the callback
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              widget.onActionComplete();
            }
          });
        } else {
          _errorMessage = result['message'];
        }
      });
    }
  }
  
  Future<void> _updateDates() async {
    // Check if campaign is not in pending state
    final approvalStatus = widget.campaign['approvalStatus']?.toString().toUpperCase() ?? '';
    final isPending = approvalStatus == 'PENDING';
    
    if (!isPending) {
      setState(() {
        _errorMessage = 'Cannot update dates: Campaign is already ${approvalStatus.toLowerCase()}';
      });
      return;
    }
    
    if (_startDate == null || _endDate == null) {
      setState(() {
        _errorMessage = 'Please set both start and end dates';
      });
      return;
    }
    
    if (_endDate!.isBefore(_startDate!)) {
      setState(() {
        _errorMessage = 'End date cannot be before start date';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    final result = await _adminCampaignService.updateCampaignDetails(
      widget.campaign['id'],
      {
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
      },
    );
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        
        if (result['success']) {
          _successMessage = 'Campaign dates updated successfully';
        } else {
          _errorMessage = result['message'];
        }
      });
    }
  }
  
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now().add(const Duration(days: 15));
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF5722),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          
          // If end date is before start date, adjust it
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate!.add(const Duration(days: 15));
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isPending = widget.campaign['approvalStatus'] == 'PENDING';
    final isApproved = widget.campaign['approvalStatus'] == 'APPROVED';
    final isRejected = widget.campaign['approvalStatus'] == 'REJECTED';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign title and status
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.campaign['title'] ?? 'Untitled Campaign',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF5722),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusChip(widget.campaign['approvalStatus']),
            ],
          ),
          
          const SizedBox(height: 16.0),
          
          // Company information
          _buildInfoSection(
            'Company Information',
            [
              _buildInfoRow('Business Name', widget.campaign['company']?['businessName'] ?? 'Unknown'),
              _buildInfoRow('Business Type', widget.campaign['company']?['businessType'] ?? 'Unknown'),
              _buildInfoRow('Email', widget.campaign['company']?['email'] ?? 'Not provided'),
              _buildInfoRow('Contact', widget.campaign['company']?['contactNumber'] ?? 'Not provided'),
            ],
          ),
          
          const Divider(height: 32.0),
          
          // Campaign details
          _buildInfoSection(
            'Campaign Details',
            [
              _buildInfoRow('Description', widget.campaign['description'] ?? 'No description'),
              _buildInfoRow('Location', widget.campaign['targetLocation'] ?? 'Not specified'),
              _buildInfoRow('Vehicle Type', widget.campaign['vehicleType'] ?? 'Not specified'),
              _buildInfoRow('Vehicle Count', (widget.campaign['vehicleCount'] ?? 0).toString()),
              _buildInfoRow('Poster Size', widget.campaign['posterSize'] ?? 'Not specified'),
              _buildInfoRow('Design Needed', (widget.campaign['posterDesignNeeded'] ?? false) ? 'Yes' : 'No'),
              _buildInfoRow(
                'Campaign Plan', 
                '${widget.campaign['plan']?['title'] ?? 'Unknown'} (${widget.campaign['plan']?['durationDays'] ?? 0} days)'
              ),
              _buildInfoRow('Total Amount', '₹${widget.campaign['totalAmount'] ?? 0}'),
            ],
          ),
          
          const Divider(height: 32.0),
          
          // Campaign poster
          if (widget.campaign['posterFile'] != null)
            _buildInfoSection(
              'Campaign Poster',
              [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    widget.campaign['posterFile'],
                    height: 200,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / 
                                loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFFFF5722),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 48.0, color: Colors.grey),
                            SizedBox(height: 8.0),
                            Text('Unable to load poster image', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          
          const Divider(height: 32.0),
          
          // Campaign scheduling
          _buildInfoSection(
            'Campaign Schedule',
            [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: isPending || isApproved
                            ? () => _selectDate(context, true) 
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                            color: isPending || isApproved ? null : Colors.grey[200],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Start Date',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                _startDate != null
                                    ? DateFormat('dd MMM yyyy').format(_startDate!)
                                    : 'Select Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _startDate != null ? Colors.black : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: isPending || isApproved
                            ? () => _selectDate(context, false) 
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                            color: isPending || isApproved ? null : Colors.grey[200],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'End Date',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                _endDate != null
                                    ? DateFormat('dd MMM yyyy').format(_endDate!)
                                    : 'Select Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _endDate != null ? Colors.black : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                  onPressed: (isPending && !_isLoading) ? _updateDates : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    minimumSize: const Size(double.infinity, 44.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    isPending 
                      ? 'Update Dates' 
                      : 'Cannot Update After ${isApproved ? 'Approval' : 'Rejection'}',
                    style: TextStyle(
                      color: isPending ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Error/Success messages
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.only(top: 16.0),
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
              margin: const EdgeInsets.only(top: 16.0),
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
          
          // Action buttons
          if (isPending)
            Container(
              margin: const EdgeInsets.only(top: 24.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campaign Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Approve button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _approveCampaign,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isLoading 
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Processing...'),
                          ],
                        )
                      : const Text('Approve Campaign'),
                  ),
                  
                  const SizedBox(height: 16.0),
                  
                  // Reject section
                  TextField(
                    controller: _rejectionReasonController,
                    decoration: InputDecoration(
                      labelText: 'Rejection Reason',
                      hintText: 'Enter reason for rejection',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 16.0),
                  
                  // Reject button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _rejectCampaign,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Reject Campaign'),
                  ),
                ],
              ),
            ),
          
          // If campaign was rejected, show rejection reason
          if (isRejected && widget.campaign['rejectionReason'] != null)
            Container(
              margin: const EdgeInsets.only(top: 24.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.red),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rejection Reason',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.campaign['rejectionReason'],
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 32.0),
          
          // Campaign Deletion Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey[300] ?? Colors.grey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delete Campaign',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'Warning: This action cannot be undone. The campaign will be permanently deleted from the system.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 16.0),
                
                // Delete button
                ElevatedButton(
                  onPressed: _isLoading || _isDeleting ? null : _showDeleteConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: _isDeleting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : const Text('Delete Campaign'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        ...children,
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(String? status) {
    Color color;
    String label;
    
    switch (status) {
      case 'APPROVED':
        color = Colors.green;
        label = 'Approved';
        break;
      case 'REJECTED':
        color = Colors.red;
        label = 'Rejected';
        break;
      case 'PENDING':
      default:
        color = Colors.orange;
        label = 'Pending';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: color, width: 1.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12.0,
        ),
      ),
    );
  }
}
