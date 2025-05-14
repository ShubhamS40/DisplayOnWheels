import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tsp/utils/constants.dart';
import 'components/campaign_image_viewer.dart';
import 'components/driver_detail_bottom_sheet.dart';
import 'components/driver_location_map.dart';

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class CampaignDetailScreen extends StatefulWidget {
  final Map<String, dynamic> campaign;

  const CampaignDetailScreen({
    Key? key,
    required this.campaign,
  }) : super(key: key);

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allocatedDrivers = [];

  // Get appropriate color based on driver status
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'ASSIGNED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'UNAVAILABLE':
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get human-readable status text
  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'ASSIGNED':
        return 'Active';
      default:
        return status.toLowerCase().capitalize();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCampaignDetails();
  }

  Future<void> _loadCampaignDetails() async {
    try {
      // Get the campaign ID from the widget
      final campaignId = widget.campaign['id'];

      if (campaignId == null) {
        throw Exception('Campaign ID not found');
      }

      // Get auth info
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Fetch campaign details from API
      final apiUrl = '${Constants.baseUrl}/api/company-dashboard/campaigns/$campaignId';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Extract allocated drivers from the response
        if (responseData.containsKey('allocatedDrivers') &&
            responseData['allocatedDrivers'] is List) {
          _allocatedDrivers = List<Map<String, dynamic>>.from(
            responseData['allocatedDrivers'].map((driver) => {
              'id': driver['id'] ?? '',
              'name': driver['name'] ?? 'Unknown Driver',
              'vehicleNumber': driver['vehicleNumber'] ?? 'No Vehicle',
              'phone': driver['phone'] ?? '',
              'status': driver['status'] ?? 'UNKNOWN',
              'lastActive': _formatLastSeen(driver['assignedAt']),
              // Add default location if needed for map view
              'location': driver['location'] != null
                  ? LatLng(
                      driver['location']['latitude'] ?? 28.6129,
                      driver['location']['longitude'] ?? 77.2295,
                    )
                  : const LatLng(28.6129, 77.2295), // Default to Delhi area
              'uploadedImages': driver['uploadedImages'] ?? [],
              'assignedAt': driver['assignedAt'],
            }),
          ).toList();
        }
      } else {
        debugPrint('Failed to fetch campaign details: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching campaign details: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Format the last seen time
  String _formatLastSeen(String? timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      final DateTime assignedTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(assignedTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  void _showDriverDetails(Map<String, dynamic> driver) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DriverDetailBottomSheet(driver: driver),
    );
  }

  void _viewCampaignPoster() {
    if (widget.campaign['posterUrl'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CampaignImageViewer(
            imageUrl: widget.campaign['posterUrl'],
            title: 'Campaign Poster',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = const Color(0xFFFF5722);
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Campaign Details',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campaign Poster
                  GestureDetector(
                    onTap: _viewCampaignPoster,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(widget.campaign['posterUrl'] ??
                              'https://via.placeholder.com/600x400?text=No+Poster+Available'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Campaign Info Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.campaign['name'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _infoRow(
                            icon: Icons.date_range,
                            title: 'Start Date',
                            value: widget.campaign['startDate'] ?? 'Not specified',
                            iconColor: accentColor,
                            textColor: textColor,
                          ),
                          const Divider(),

                          _infoRow(
                            icon: Icons.event_busy,
                            title: 'End Date',
                            value: widget.campaign['endDate'] ?? 'Not specified',
                            iconColor: accentColor,
                            textColor: textColor,
                          ),
                          const Divider(),

                          _infoRow(
                            icon: Icons.credit_card,
                            title: 'Plan',
                            value: widget.campaign['planName'] ?? 'Basic Plan',
                            iconColor: accentColor,
                            textColor: textColor,
                          ),
                          const Divider(),

                          _infoRow(
                            icon: Icons.description,
                            title: 'Description',
                            value: widget.campaign['description'] ?? 'No description provided',
                            iconColor: accentColor,
                            textColor: textColor,
                          ),
                          const Divider(),

                          _infoRow(
                            icon: Icons.directions_car,
                            title: 'Allocated Drivers',
                            value: _allocatedDrivers.length.toString(),
                            iconColor: accentColor,
                            textColor: textColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Allocated Drivers Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Allocated Drivers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        if (_allocatedDrivers.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DriverLocationMap(drivers: _allocatedDrivers),
                                ),
                              );
                            },
                            icon: Icon(Icons.map_outlined, color: accentColor, size: 18),
                            label: Text(
                              'View on Map',
                              style: TextStyle(color: accentColor),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: accentColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _allocatedDrivers.length,
                    itemBuilder: (context, index) {
                      final driver = _allocatedDrivers[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: accentColor,
                            child: Text(
                              driver['name'].substring(0, 1),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            driver['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver['vehicleNumber'],
                                style: TextStyle(color: textColor.withOpacity(0.7)),
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(driver['status']),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getStatusText(driver['status']),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Last seen: ${driver['lastActive']}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: textColor.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: accentColor,
                            ),
                          ),
                          onTap: () => _showDriverDetails(driver),
                        ),
                      );
                    },
                  ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }
  
  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
