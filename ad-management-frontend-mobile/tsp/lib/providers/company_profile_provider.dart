import 'package:flutter/material.dart';
import '../models/company_profile_model.dart';
import '../services/company_profile_service.dart';

class CompanyProfileProvider extends ChangeNotifier {
  final CompanyProfileService _service = CompanyProfileService();
  
  CompanyProfileModel? _companyProfile;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  CompanyProfileModel? get companyProfile => _companyProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Fetch company profile data
  Future<void> fetchCompanyProfile(String companyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final profile = await _service.getCompanyProfile(companyId);
      _companyProfile = profile;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Helper methods for accessing specific data
  CompanyBasicDetails? get basicDetails => _companyProfile?.basicDetails;
  DocumentDetails? get documentDetails => _companyProfile?.documentDetails;
  List<CampaignData> get campaigns => _companyProfile?.campaigns ?? [];
  List<PaymentData> get payments => _companyProfile?.payments ?? [];
  
  // Helper method to check verification status
  bool get isVerified => _companyProfile?.documentDetails?.verificationStatus?.overall == "APPROVED";
  
  // Helper method to get wallet balance
  double get walletBalance => _companyProfile?.basicDetails?.walletBalance ?? 0.0;

  // Update company profile data
  Future<void> updateCompanyProfile(String companyId, Map<String, dynamic> updatedData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _service.updateCompanyProfile(companyId, updatedData);
      // Refetch the profile to get updated data
      await fetchCompanyProfile(companyId);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
