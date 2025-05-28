class VerifiedCompanyResponse {
  final bool success;
  final String message;
  final List<VerifiedCompany> data;

  VerifiedCompanyResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory VerifiedCompanyResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] ?? [];
    
    return VerifiedCompanyResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: dataList.map((item) => VerifiedCompany.fromJson(item)).toList(),
    );
  }
}

class VerifiedCompany {
  final String id;
  final String businessName;
  final String email;

  VerifiedCompany({
    required this.id,
    required this.businessName,
    required this.email,
  });

  factory VerifiedCompany.fromJson(Map<String, dynamic> json) {
    return VerifiedCompany(
      id: json['id'] ?? '',
      businessName: json['businessName'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
