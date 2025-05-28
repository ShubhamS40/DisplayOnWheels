class DriverLocationData {
  final String driverId;
  final String campaignDriverId;
  final String campaignId;
  final String campaignTitle;
  final String name;
  final String phone;
  final String email;
  final String vehicleNumber;
  final String vehicleType;
  final bool isActive;
  final bool isAssigned;
  final double latitude;
  final double longitude;
  final String timestamp;
  final String lastUpdateAgo;

  DriverLocationData({
    required this.driverId,
    required this.campaignDriverId,
    required this.campaignId,
    required this.campaignTitle,
    required this.name,
    required this.phone,
    required this.email,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.isActive,
    required this.isAssigned,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.lastUpdateAgo,
  });

  factory DriverLocationData.fromJson(Map<String, dynamic> json) {
    return DriverLocationData(
      driverId: json['driverId'] as String,
      campaignDriverId: json['campaignDriverId'] as String,
      campaignId: json['campaignId'] as String,
      campaignTitle: json['campaignTitle'] as String? ?? 'Unknown Campaign',
      name: json['name'] as String? ?? 'Unknown Driver',
      phone: json['phone'] as String? ?? 'N/A',
      email: json['email'] as String? ?? 'N/A',
      vehicleNumber: json['vehicleNumber'] as String? ?? 'N/A',
      vehicleType: json['vehicleType'] as String? ?? 'Unknown',
      isActive: json['isActive'] as bool? ?? false,
      isAssigned: json['isAssigned'] as bool? ?? true,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      lastUpdateAgo: json['lastUpdateAgo'] as String? ?? 'Unknown',
    );
  }
}
