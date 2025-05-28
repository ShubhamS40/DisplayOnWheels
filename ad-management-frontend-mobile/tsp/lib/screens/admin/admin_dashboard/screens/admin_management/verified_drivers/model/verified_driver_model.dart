class VerifiedDriver {
  final String id;
  final String fullName;
  final String email;

  VerifiedDriver({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory VerifiedDriver.fromJson(Map<String, dynamic> json) {
    return VerifiedDriver(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class VerifiedDriversResponse {
  final bool success;
  final List<VerifiedDriver> data;

  VerifiedDriversResponse({
    required this.success,
    required this.data,
  });

  factory VerifiedDriversResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> driversList = json['data'] ?? [];
    
    return VerifiedDriversResponse(
      success: json['success'] ?? false,
      data: driversList
          .map((driverJson) => VerifiedDriver.fromJson(driverJson))
          .toList(),
    );
  }
}
