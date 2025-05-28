import 'package:flutter/material.dart';
import '../models/driver_profile_model.dart';
import '../services/driver_profile_service.dart';

class DriverProfileProvider extends ChangeNotifier {
  final DriverProfileService _service = DriverProfileService();
  
  DriverProfileModel? _driverProfile;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  DriverProfileModel? get driverProfile => _driverProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Fetch driver profile data
  Future<void> fetchDriverProfile(String driverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final profile = await _service.getDriverProfile(driverId);
      _driverProfile = profile;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Helper methods for accessing specific data
  BasicDetails? get basicDetails => _driverProfile?.basicDetails;
  VehicleDetails? get vehicleDetails => _driverProfile?.vehicleDetails;
  DocumentDetails? get documentDetails => _driverProfile?.documentDetails;
  BankDetails? get bankDetails => _driverProfile?.bankDetails;
  List<CampaignData> get campaigns => _driverProfile?.campaigns ?? [];
}
