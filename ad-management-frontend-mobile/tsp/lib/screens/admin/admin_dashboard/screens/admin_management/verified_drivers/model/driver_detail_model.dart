class DriverDetailResponse {
  final bool success;
  final String message;
  final DriverDetailData data;

  DriverDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DriverDetailResponse.fromJson(Map<String, dynamic> json) {
    return DriverDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: DriverDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class DriverDetailData {
  final BasicDetails basicDetails;
  final VehicleDetails vehicleDetails;
  final DocumentDetails documentDetails;
  final List<AssignedCampaign> assignedCampaigns;

  DriverDetailData({
    required this.basicDetails,
    required this.vehicleDetails,
    required this.documentDetails,
    required this.assignedCampaigns,
  });

  factory DriverDetailData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> campaignsList = json['assignedCampaigns'] ?? [];
    
    return DriverDetailData(
      basicDetails: BasicDetails.fromJson(json['basicDetails'] ?? {}),
      vehicleDetails: VehicleDetails.fromJson(json['vehicleDetails'] ?? {}),
      documentDetails: DocumentDetails.fromJson(json['documentDetails'] ?? {}),
      assignedCampaigns: campaignsList
          .map((campaign) => AssignedCampaign.fromJson(campaign))
          .toList(),
    );
  }
}

class BasicDetails {
  final String id;
  final String fullName;
  final String email;
  final String contactNumber;
  final bool isEmailVerified;
  final bool isAvailable;
  final double walletBalance;
  final String createdAt;
  final String updatedAt;
  final Location? currentLocation;

  BasicDetails({
    required this.id,
    required this.fullName,
    required this.email,
    required this.contactNumber,
    required this.isEmailVerified,
    required this.isAvailable,
    required this.walletBalance,
    required this.createdAt,
    required this.updatedAt,
    this.currentLocation,
  });

  factory BasicDetails.fromJson(Map<String, dynamic> json) {
    return BasicDetails(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      isAvailable: json['isAvailable'] ?? false,
      walletBalance: (json['walletBalance'] is int)
          ? (json['walletBalance'] as int).toDouble()
          : json['walletBalance'] ?? 0.0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      currentLocation: json['currentLocation'] != null
          ? Location.fromJson(json['currentLocation'])
          : null,
    );
  }
}

class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'] is int
          ? (json['lat'] as int).toDouble()
          : json['lat'] ?? 0.0,
      lng: json['lng'] is int
          ? (json['lng'] as int).toDouble()
          : json['lng'] ?? 0.0,
    );
  }
}

class VehicleDetails {
  final String vehicleType;
  final String vehicleNumber;

  VehicleDetails({
    required this.vehicleType,
    required this.vehicleNumber,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      vehicleType: json['vehicleType'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
    );
  }
}

class DocumentDetails {
  final Photos photos;
  final VerificationStatus verificationStatus;
  final BankDetails bank;

  DocumentDetails({
    required this.photos,
    required this.verificationStatus,
    required this.bank,
  });

  factory DocumentDetails.fromJson(Map<String, dynamic> json) {
    return DocumentDetails(
      photos: Photos.fromJson(json['photos'] ?? {}),
      verificationStatus: VerificationStatus.fromJson(json['verificationStatus'] ?? {}),
      bank: BankDetails.fromJson(json['bank'] ?? {}),
    );
  }
}

class Photos {
  final String profilePhoto;
  final String idCard;
  final String drivingLicense;
  final String vehicleImage;
  final String bankProof;

  Photos({
    required this.profilePhoto,
    required this.idCard,
    required this.drivingLicense,
    required this.vehicleImage,
    required this.bankProof,
  });

  factory Photos.fromJson(Map<String, dynamic> json) {
    return Photos(
      profilePhoto: json['profilePhoto'] ?? '',
      idCard: json['idCard'] ?? '',
      drivingLicense: json['drivingLicense'] ?? '',
      vehicleImage: json['vehicleImage'] ?? '',
      bankProof: json['bankProof'] ?? '',
    );
  }
}

class VerificationStatus {
  final String photo;
  final String idCard;
  final String drivingLicense;
  final String vehicleImage;
  final String bankProof;
  final String overall;
  final String? adminMessage;

  VerificationStatus({
    required this.photo,
    required this.idCard,
    required this.drivingLicense,
    required this.vehicleImage,
    required this.bankProof,
    required this.overall,
    this.adminMessage,
  });

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      photo: json['photo'] ?? '',
      idCard: json['idCard'] ?? '',
      drivingLicense: json['drivingLicense'] ?? '',
      vehicleImage: json['vehicleImage'] ?? '',
      bankProof: json['bankProof'] ?? '',
      overall: json['overall'] ?? '',
      adminMessage: json['adminMessage'],
    );
  }
}

class BankDetails {
  final String branchName;
  final String bankName;
  final String ifscCode;
  final String accountNumber;

  BankDetails({
    required this.branchName,
    required this.bankName,
    required this.ifscCode,
    required this.accountNumber,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      branchName: json['branchName'] ?? '',
      bankName: json['bankName'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
    );
  }
}

class AssignedCampaign {
  final String status;
  final String assignedAt;
  final double earnings;
  final String? proofPhotoUrl;
  final CampaignInfo campaign;

  AssignedCampaign({
    required this.status,
    required this.assignedAt,
    required this.earnings,
    this.proofPhotoUrl,
    required this.campaign,
  });

  factory AssignedCampaign.fromJson(Map<String, dynamic> json) {
    return AssignedCampaign(
      status: json['status'] ?? '',
      assignedAt: json['assignedAt'] ?? '',
      earnings: (json['earnings'] is int)
          ? (json['earnings'] as int).toDouble()
          : json['earnings'] ?? 0.0,
      proofPhotoUrl: json['proofPhotoUrl'],
      campaign: CampaignInfo.fromJson(json['campaign'] ?? {}),
    );
  }
}

class CampaignInfo {
  final String id;
  final String title;
  final String status;
  final CompanyInfo company;

  CampaignInfo({
    required this.id,
    required this.title,
    required this.status,
    required this.company,
  });

  factory CampaignInfo.fromJson(Map<String, dynamic> json) {
    return CampaignInfo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      company: CompanyInfo.fromJson(json['company'] ?? {}),
    );
  }
}

class CompanyInfo {
  final String id;
  final String businessName;
  final String email;

  CompanyInfo({
    required this.id,
    required this.businessName,
    required this.email,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      id: json['id'] ?? '',
      businessName: json['businessName'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
