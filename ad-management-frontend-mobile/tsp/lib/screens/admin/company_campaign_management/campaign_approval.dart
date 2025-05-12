import 'package:flutter/material.dart';
import 'package:tsp/screens/admin/company_campaign_management/components/campaign_list.dart';
import 'package:tsp/screens/admin/company_campaign_management/components/campaign_detail.dart';
import 'package:tsp/screens/admin/company_campaign_management/components/driver_assignment.dart';
import 'package:tsp/services/admin/admin_campaign_service.dart';

class CampaignApprovalScreen extends StatefulWidget {
  const CampaignApprovalScreen({Key? key}) : super(key: key);

  @override
  State<CampaignApprovalScreen> createState() => _CampaignApprovalScreenState();
}

class _CampaignApprovalScreenState extends State<CampaignApprovalScreen> with SingleTickerProviderStateMixin {
  final AdminCampaignService _adminCampaignService = AdminCampaignService();
  Map<String, dynamic>? _selectedCampaign;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _onCampaignSelected(Map<String, dynamic> campaign) {
    setState(() {
      _selectedCampaign = campaign;
    });
  }
  
  void _refreshCampaign() async {
    if (_selectedCampaign == null) return;
    
    final campaigns = await _adminCampaignService.getAllCampaigns();
    final updatedCampaign = campaigns.firstWhere(
      (c) => c['id'] == _selectedCampaign!['id'],
      orElse: () => _selectedCampaign!,
    );
    
    if (mounted) {
      setState(() {
        _selectedCampaign = updatedCampaign;
      });
    }
  }
  
  void _onActionComplete() {
    _refreshCampaign();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Campaign Management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFF5722),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: _selectedCampaign != null
            ? TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Campaign Details'),
                  Tab(text: 'Driver Assignment'),
                ],
              )
            : null,
        actions: [
          if (_selectedCampaign != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _selectedCampaign = null;
                });
              },
              tooltip: 'Back to campaign list',
            ),
        ],
      ),
      body: _selectedCampaign == null
          ? CampaignList(onCampaignSelected: _onCampaignSelected)
          : TabBarView(
              controller: _tabController,
              children: [
                // Campaign Details Tab
                CampaignDetail(
                  campaign: _selectedCampaign!,
                  onActionComplete: _onActionComplete,
                ),
                
                // Driver Assignment Tab
                DriverAssignment(
                  campaign: _selectedCampaign!,
                  onAssignmentComplete: _onActionComplete,
                ),
              ],
            ),
    );
  }
}