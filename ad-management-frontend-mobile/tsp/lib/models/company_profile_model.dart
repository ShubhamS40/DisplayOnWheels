class CompanyProfileModel {
  final CompanyBasicDetails basicDetails;
  final List<CampaignData> campaigns;
  final DocumentDetails? documentDetails;
  final List<PaymentData>? payments;
  // We'll create a calculated statistics object since the API doesn't directly provide it
  final StatisticsData? statistics;

  CompanyProfileModel({
    required this.basicDetails,
    required this.campaigns,
    this.documentDetails,
    this.payments,
    this.statistics,
  });

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    // Create statistics based on available data
    final campaigns = (json['campaigns'] as List<dynamic>?)
            ?.map((campaign) => CampaignData.fromJson(campaign))
            .toList() ??
        [];

    final payments = (json['payments'] as List<dynamic>?)
            ?.map((payment) => PaymentData.fromJson(payment))
            .toList() ??
        [];

    // Calculate statistics from campaigns and payments
    final activeCampaigns = campaigns
        .where((c) =>
            c.status == 'ACTIVE' ||
            c.status == 'PENDING_PAYMENT' ||
            c.status == 'PENDING')
        .length;
    final completedCampaigns =
        campaigns.where((c) => c.status == 'COMPLETED').length;
    final totalSpent = payments
        .where((p) => p.status == 'COMPLETED' && !p.refunded)
        .fold(0.0, (sum, payment) => sum + payment.amount);

    final statistics = StatisticsData(
      totalCampaigns: campaigns.length,
      activeCampaigns: activeCampaigns,
      completedCampaigns: completedCampaigns,
      totalSpent: totalSpent,
    );

    return CompanyProfileModel(
      basicDetails: CompanyBasicDetails.fromJson(json['basicDetails'] ?? {}),
      campaigns: campaigns,
      documentDetails: json['documentDetails'] != null
          ? DocumentDetails.fromJson(json['documentDetails'])
          : null,
      payments: payments,
      statistics: statistics,
    );
  }
}

class CompanyBasicDetails {
  final String id;
  final String businessName;
  final String? businessType;
  final String email;
  final String contactNumber;
  final bool isEmailVerified;
  final double walletBalance;
  final String createdAt;
  final String updatedAt;
  final String? logoUrl;
  final bool isVerified;

  CompanyBasicDetails({
    required this.id,
    required this.businessName,
    this.businessType,
    required this.email,
    required this.contactNumber,
    required this.isEmailVerified,
    required this.walletBalance,
    required this.createdAt,
    required this.updatedAt,
    this.logoUrl,
    this.isVerified = false,
  });

  factory CompanyBasicDetails.fromJson(Map<String, dynamic> json) {
    return CompanyBasicDetails(
      id: json['id'] ?? '',
      businessName: json['businessName'] ?? '',
      businessType: json['businessType'],
      email: json['email'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      logoUrl: json['logoUrl'],
      isVerified: json['isVerified'] ?? false,
    );
  }
}

class DocumentDetails {
  final DocumentUrls documentUrls;
  final CompanyInfo companyInfo;
  final VerificationStatus verificationStatus;

  DocumentDetails({
    required this.documentUrls,
    required this.companyInfo,
    required this.verificationStatus,
  });

  factory DocumentDetails.fromJson(Map<String, dynamic> json) {
    // Parse document details according to the API response structure
    return DocumentDetails(
      documentUrls: json['urls'] != null 
          ? DocumentUrls.fromJson(json['urls']) 
          : DocumentUrls(
              businessRegistrationUrl: '',
              idCardUrl: '',
              gstRegistrationUrl: '',
              panCardUrl: '',
            ),
      companyInfo: json['companyInfo'] != null 
          ? CompanyInfo.fromJson(json['companyInfo']) 
          : CompanyInfo(
              name: '',
              type: '',
              address: '',
              city: '',
              state: '',
              country: '',
              zipCode: '',
              registrationNumber: '',
              taxId: '',
            ),
      verificationStatus: json['verificationStatus'] != null 
          ? VerificationStatus.fromJson(json['verificationStatus']) 
          : VerificationStatus(
              businessRegistration: '',
              idCardStatus: '',
              gstRegistration: '',
              panCard: '',
              overall: '',
              adminMessage: null,
            ),
    );
  }
}

class DocumentUrls {
  final String businessRegistrationUrl;
  final String idCardUrl;
  final String gstRegistrationUrl;
  final String panCardUrl;

  DocumentUrls({
    required this.businessRegistrationUrl,
    required this.idCardUrl,
    required this.gstRegistrationUrl,
    required this.panCardUrl,
  });

  factory DocumentUrls.fromJson(Map<String, dynamic> json) {
    return DocumentUrls(
      businessRegistrationUrl: json['registrationDoc']?.toString().trim() ?? '',
      idCardUrl: json['idCard']?.toString().trim() ?? '',
      gstRegistrationUrl: json['gstNumber']?.toString().trim() ?? '',
      panCardUrl: '', // Not provided in the current API response
    );
  }
}

class CompanyInfo {
  final String name;
  final String type;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final String registrationNumber;
  final String taxId;

  CompanyInfo({
    required this.name,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
    required this.registrationNumber,
    required this.taxId,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zipCode: json['zipCode'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      taxId: json['taxId'] ?? '',
    );
  }
}

class VerificationStatus {
  final String businessRegistration;
  final String idCardStatus;
  final String gstRegistration;
  final String panCard;
  final String overall;
  final String? adminMessage;

  VerificationStatus({
    required this.businessRegistration,
    required this.idCardStatus,
    required this.gstRegistration,
    required this.panCard,
    required this.overall,
    this.adminMessage,
  });

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      businessRegistration: json['registrationStatus'] ?? '',
      idCardStatus: json['idCardStatus'] ?? '',
      gstRegistration: json['gstStatus'] ?? '',
      panCard: '', // Not provided in the current API response
      overall: json['overall'] ?? '',
      adminMessage: json['adminMessage'],
    );
  }
}

class StatisticsData {
  final int totalCampaigns;
  final int activeCampaigns;
  final int completedCampaigns;
  final double totalSpent;

  StatisticsData({
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.completedCampaigns,
    required this.totalSpent,
  });

  factory StatisticsData.fromJson(Map<String, dynamic> json) {
    return StatisticsData(
      totalCampaigns: json['totalCampaigns'] ?? 0,
      activeCampaigns: json['activeCampaigns'] ?? 0,
      completedCampaigns: json['completedCampaigns'] ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CampaignData {
  final String id;
  final String title;
  final String status;
  final String approvalStatus;
  final double totalAmount;
  final String? startDate;
  final String? endDate;
  final int vehicleCount;
  final String? posterFile;
  final bool posterDesignNeeded;
  final String? approvedAt;
  final double? budget;
  final List<dynamic>? assignedDrivers;
  final String? posterUrl;

  CampaignData({
    required this.id,
    required this.title,
    required this.status,
    required this.approvalStatus,
    required this.totalAmount,
    this.startDate,
    this.endDate,
    required this.vehicleCount,
    this.posterFile,
    required this.posterDesignNeeded,
    this.approvedAt,
    this.budget,
    this.assignedDrivers,
    this.posterUrl,
  });

  factory CampaignData.fromJson(Map<String, dynamic> json) {
    return CampaignData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      approvalStatus: json['approvalStatus'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      startDate: json['startDate'],
      endDate: json['endDate'],
      vehicleCount: json['vehicleCount'] ?? 0,
      posterFile: json['posterFile'],
      posterDesignNeeded: json['posterDesignNeeded'] ?? false,
      approvedAt: json['approvedAt'],
      budget: (json['budget'] as num?)?.toDouble() ??
          (json['totalAmount'] as num?)?.toDouble() ??
          0.0,
      assignedDrivers: json['assignedDrivers'] as List<dynamic>? ?? [],
      posterUrl: json['posterUrl'] ?? json['posterFile'] ?? '',
    );
  }
}

class PaymentData {
  final String id;
  final double amount;
  final String status;
  final String method;
  final String transactionId;
  final bool refunded;
  final String? refundReason;
  final String? refundedAt;
  final String? proof;
  final String date;

  PaymentData({
    required this.id,
    required this.amount,
    required this.status,
    required this.method,
    required this.transactionId,
    required this.refunded,
    this.refundReason,
    this.refundedAt,
    this.proof,
    required this.date,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      id: json['id'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      method: json['method'] ?? '',
      transactionId: json['transactionId'] ?? '',
      refunded: json['refunded'] ?? false,
      refundReason: json['refundReason'],
      refundedAt: json['refundedAt'],
      proof: json['proof'],
      date: json['date'] ?? '',
    );
  }
}
