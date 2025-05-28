class DriverLocationData {
  final String driverId;
  final String name;
  final String? phone;
  final String? vehicleNumber;
  final String? vehicleType;
  final String? profileImage;
  final bool isActive;
  final bool isApproved;
  final double latitude;
  final double longitude;
  final String timestamp;
  final String lastUpdateAgo;

  DriverLocationData({
    required this.driverId,
    required this.name,
    this.phone,
    this.vehicleNumber,
    this.vehicleType,
    this.profileImage,
    required this.isActive,
    required this.isApproved,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.lastUpdateAgo,
  });

  factory DriverLocationData.fromJson(Map<String, dynamic> json) {
    return DriverLocationData(
      driverId: json['driverId'] as String,
      name: json['name'] as String? ?? 'Unknown Driver',
      phone: json['phone'] as String?,
      vehicleNumber: json['vehicleNumber'] as String?,
      vehicleType: json['vehicleType'] as String?,
      profileImage: json['profileImage'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      isApproved: json['isApproved'] as bool? ?? false,
      latitude: (json['lat'] is double)
          ? json['lat']
          : double.parse(json['lat'].toString()),
      longitude: (json['lng'] is double)
          ? json['lng']
          : double.parse(json['lng'].toString()),
      timestamp:
          json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      lastUpdateAgo: json['lastUpdateAgo'] as String? ?? 'Unknown',
    );
  }
}
