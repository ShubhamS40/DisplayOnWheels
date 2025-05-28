class DriverProfileModel {
  final BasicDetails basicDetails;
  final VehicleDetails vehicleDetails;
  final DocumentDetails? documentDetails;
  final BankDetails? bankDetails;
  final List<CampaignData> campaigns;

  DriverProfileModel({
    required this.basicDetails,
    required this.vehicleDetails,
    this.documentDetails,
    this.bankDetails,
    required this.campaigns,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      basicDetails: BasicDetails.fromJson(json['basicDetails']),
      vehicleDetails: VehicleDetails.fromJson(json['vehicleDetails']),
      documentDetails: json['documentDetails'] != null
          ? DocumentDetails.fromJson(json['documentDetails'])
          : null,
      bankDetails: json['bankDetails'] != null
          ? BankDetails.fromJson(json['bankDetails'])
          : null,
      campaigns: (json['campaigns'] as List)
          .map((e) => CampaignData.fromJson(e))
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
  final DateTime createdAt;
  final DateTime updatedAt;

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
  });

  factory BasicDetails.fromJson(Map<String, dynamic> json) {
    return BasicDetails(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      contactNumber: json['contactNumber'],
      isEmailVerified: json['isEmailVerified'],
      isAvailable: json['isAvailable'],
      walletBalance: json['walletBalance'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
      vehicleType: json['vehicleType'],
      vehicleNumber: json['vehicleNumber'],
    );
  }
}

class DocumentDetails {
  final DocumentPhotos photos;
  final VerificationStatus verificationStatus;

  DocumentDetails({
    required this.photos,
    required this.verificationStatus,
  });

  factory DocumentDetails.fromJson(Map<String, dynamic> json) {
    return DocumentDetails(
      photos: DocumentPhotos.fromJson(json['photos']),
      verificationStatus:
          VerificationStatus.fromJson(json['verificationStatus']),
    );
  }
}

class DocumentPhotos {
  final String profilePhoto;
  final String idCard;
  final String drivingLicense;
  final String vehicleImage;
  final String bankProof;

  DocumentPhotos({
    required this.profilePhoto,
    required this.idCard,
    required this.drivingLicense,
    required this.vehicleImage,
    required this.bankProof,
  });

  factory DocumentPhotos.fromJson(Map<String, dynamic> json) {
    return DocumentPhotos(
      profilePhoto: json['profilePhoto'],
      idCard: json['idCard'],
      drivingLicense: json['drivingLicense'],
      vehicleImage: json['vehicleImage'],
      bankProof: json['bankProof'],
    );
  }
}

class VerificationStatus {
  final String profilePhoto;
  final String idCard;
  final String drivingLicense;
  final String vehicleImage;
  final String bankProof;
  final String overall;
  final String? adminMessage;

  VerificationStatus({
    required this.profilePhoto,
    required this.idCard,
    required this.drivingLicense,
    required this.vehicleImage,
    required this.bankProof,
    required this.overall,
    this.adminMessage,
  });

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      profilePhoto: json['profilePhoto'],
      idCard: json['idCard'],
      drivingLicense: json['drivingLicense'],
      vehicleImage: json['vehicleImage'],
      bankProof: json['bankProof'],
      overall: json['overall'],
      adminMessage: json['adminMessage'],
    );
  }

  get vehicleStatus => null;
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
      branchName: json['branchName'],
      bankName: json['bankName'],
      ifscCode: json['ifscCode'],
      accountNumber: json['accountNumber'],
    );
  }
}

class CampaignData {
  final String id;
  final String title;
  final String campaignStatus;
  final String driverStatus;
  final DateTime assignedAt;
  final String? proofPhoto;
  final double earnings;

  CampaignData({
    required this.id,
    required this.title,
    required this.campaignStatus,
    required this.driverStatus,
    required this.assignedAt,
    this.proofPhoto,
    required this.earnings,
  });

  factory CampaignData.fromJson(Map<String, dynamic> json) {
    return CampaignData(
      id: json['id'],
      title: json['title'],
      campaignStatus: json['campaignStatus'],
      driverStatus: json['driverStatus'],
      assignedAt: DateTime.parse(json['assignedAt']),
      proofPhoto: json['proofPhoto'],
      earnings: json['earnings'].toDouble(),
    );
  }
}
