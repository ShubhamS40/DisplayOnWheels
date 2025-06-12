import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final driverIdProvider = StateProvider<String?>((ref) => null);
final companyIdProvider = StateProvider<String?>((ref) => null);
final rechargePlanIdProvider = StateProvider<String?>((ref) => null);

// Initialize providers from SharedPreferences
Future<void> initializeProviders(ProviderContainer container) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // Get stored IDs from SharedPreferences
    final driverId = prefs.getString('driverId');
    final companyId = prefs.getString('companyId');
    final rechargePlanId = prefs.getString('rechargePlanId');

    // Update providers if values exist
    if (driverId != null) {
      container.read(driverIdProvider.notifier).state = driverId;
    }

    if (companyId != null) {
      container.read(companyIdProvider.notifier).state = companyId;
    }

    if (rechargePlanId != null) {
      container.read(rechargePlanIdProvider.notifier).state = rechargePlanId;
    }
  } catch (e) {
    print('Error initializing providers: $e');
  }
}
