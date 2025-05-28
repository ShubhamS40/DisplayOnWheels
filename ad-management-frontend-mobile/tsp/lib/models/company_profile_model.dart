class CompanyProfileModel {
  final CompanyBasicDetails basicDetails;
  final List<CampaignData> campaigns;
  final AccountDetails accountDetails;
  final StatisticsData statistics;

  CompanyProfileModel({
    required this.basicDetails,
    required this.campaigns,
    required this.accountDetails,
    required this.statistics,
  });

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileModel(
      basicDetails: CompanyBasicDetails.fromJson(json['basicDetails'] ?? {}),
      campaigns: (json['campaigns'] as List<dynamic>?)
              ?.map((campaign) => CampaignData.fromJson(campaign))
              .toList() ??
          [],
      accountDetails: AccountDetails.fromJson(json['accountDetails'] ?? {}),
      statistics: StatisticsData.fromJson(json['statistics'] ?? {}),
    );
  }
}

class CompanyBasicDetails {
  final String id;
  final String companyName;
  final String email;
  final String contactNumber;
  final String address;
  final String registrationNumber;
  final String logoUrl;
  final double walletBalance;
  final bool isVerified;
  final String accountCreated;

  CompanyBasicDetails({
    required this.id,
    required this.companyName,
    required this.email,
    required this.contactNumber,
    required this.address,
    required this.registrationNumber,
    required this.logoUrl,
    required this.walletBalance,
    required this.isVerified,
    required this.accountCreated,
  });

  factory CompanyBasicDetails.fromJson(Map<String, dynamic> json) {
    return CompanyBasicDetails(
      id: json['id'] ?? '',
      companyName: json['companyName'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      address: json['address'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['isVerified'] ?? false,
      accountCreated: json['accountCreated'] ?? '',
    );
  }
}

class AccountDetails {
  final String planType;
  final String planExpiryDate;
  final double planAmount;
  final bool autoRenewal;

  AccountDetails({
    required this.planType,
    required this.planExpiryDate,
    required this.planAmount,
    required this.autoRenewal,
  });

  factory AccountDetails.fromJson(Map<String, dynamic> json) {
    return AccountDetails(
      planType: json['planType'] ?? '',
      planExpiryDate: json['planExpiryDate'] ?? '',
      planAmount: (json['planAmount'] as num?)?.toDouble() ?? 0.0,
      autoRenewal: json['autoRenewal'] ?? false,
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
  final String startDate;
  final String endDate;
  final int assignedDrivers;
  final double budget;
  final String posterUrl;

  CampaignData({
    required this.id,
    required this.title,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.assignedDrivers,
    required this.budget,
    required this.posterUrl,
  });

  factory CampaignData.fromJson(Map<String, dynamic> json) {
    return CampaignData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      assignedDrivers: json['assignedDrivers'] ?? 0,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      posterUrl: json['posterUrl'] ?? '',
    );
  }
}
