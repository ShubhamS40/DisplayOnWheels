import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tsp/services/admin/admin_campaign_service.dart';

class CampaignList extends StatefulWidget {
  final Function(Map<String, dynamic>) onCampaignSelected;
  
  const CampaignList({
    Key? key,
    required this.onCampaignSelected,
  }) : super(key: key);

  @override
  State<CampaignList> createState() => _CampaignListState();
}

class _CampaignListState extends State<CampaignList> {
  final AdminCampaignService _adminCampaignService = AdminCampaignService();
  List<dynamic> _campaigns = [];
  bool _isLoading = true;
  String _filterStatus = 'All';
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }
  
  Future<void> _fetchCampaigns() async {
    setState(() {
      _isLoading = true;
    });
    
    final campaigns = await _adminCampaignService.getAllCampaigns();
    
    if (mounted) {
      setState(() {
        _campaigns = campaigns;
        _isLoading = false;
      });
    }
  }
  
  List<dynamic> get _filteredCampaigns {
    return _campaigns.where((campaign) {
      // Filter by status
      if (_filterStatus != 'All' && campaign['approvalStatus'] != _filterStatus) {
        return false;
      }
      
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final title = campaign['title']?.toString().toLowerCase() ?? '';
        final company = campaign['company']?['businessName']?.toString().toLowerCase() ?? '';
        final location = campaign['targetLocation']?.toString().toLowerCase() ?? '';
        
        return title.contains(_searchQuery.toLowerCase()) || 
               company.contains(_searchQuery.toLowerCase()) || 
               location.contains(_searchQuery.toLowerCase());
      }
      
      return true;
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Campaign Management',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF5722),
            ),
          ),
        ),
        
        // Search & Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search campaigns...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16.0),
              DropdownButton<String>(
                value: _filterStatus,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                  DropdownMenuItem(value: 'APPROVED', child: Text('Approved')),
                  DropdownMenuItem(value: 'REJECTED', child: Text('Rejected')),
                ],
                onChanged: (value) {
                  setState(() {
                    _filterStatus = value ?? 'All';
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchCampaigns,
              ),
            ],
          ),
        ),
        
        // Campaign List
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
            : _filteredCampaigns.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isNotEmpty || _filterStatus != 'All'
                        ? 'No campaigns match your filters'
                        : 'No campaigns available',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCampaigns.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemBuilder: (context, index) {
                      final campaign = _filteredCampaigns[index];
                      final hasStartDate = campaign['startDate'] != null;
                      final hasEndDate = campaign['endDate'] != null;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: InkWell(
                          onTap: () => widget.onCampaignSelected(campaign),
                          borderRadius: BorderRadius.circular(12.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        campaign['title'] ?? 'Untitled Campaign',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    _buildStatusChip(campaign['approvalStatus']),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Company: ${campaign['company']?['businessName'] ?? 'Unknown'}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Location: ${campaign['targetLocation'] ?? 'Not specified'}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Vehicle Type: ${campaign['vehicleType'] ?? 'Not specified'} (${campaign['vehicleCount'] ?? 0})',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Plan: ${campaign['plan']?['title'] ?? 'Unknown'} (₹${campaign['totalAmount'] ?? 0})',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today, 
                                      size: 16.0,
                                      color: hasStartDate && hasEndDate 
                                        ? Colors.green 
                                        : Colors.grey,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      hasStartDate && hasEndDate
                                        ? '${_formatDate(campaign['startDate'])} - ${_formatDate(campaign['endDate'])}'
                                        : 'No dates scheduled',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: hasStartDate && hasEndDate 
                                          ? Colors.green 
                                          : Colors.grey,
                                        fontWeight: hasStartDate && hasEndDate
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14.0,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
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
  
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return 'Invalid date';
    }
  }
}
