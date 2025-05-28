import 'package:flutter/material.dart';
import 'package:tsp/models/recharge_plan.dart';
import 'package:tsp/screens/admin/admin_dashboard/screens/admin_management/admin_management_screen.dart';
import 'package:tsp/screens/admin/admin_dashboard/screens/admin_management/setRechargePlan/setrecharge_plan.dart';
import 'package:tsp/screens/admin/company_campaign_management/campaign_approval.dart';
import 'package:tsp/screens/admin/company_documentsVerification/company_lists_not_verifiedDocuments.dart';
import 'package:tsp/screens/admin/driver_documentsVerification/driver_lists_not_verifiedDocumnets.dart';
import 'package:tsp/screens/admin/admin_dashboard/screens/admin_management/drivers_livelocation/admin_drivers_map_screen.dart';

import 'package:tsp/screens/auth/role_selection.dart';

import 'package:tsp/screens/company/company_document/company_upload_documents.dart';
import 'package:tsp/screens/company/company_document/company_verification_stage.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/ad_campaign_screen.dart';
import 'package:tsp/screens/company/company_recharge_plan/ad_recharge_plan_screen.dart';

import 'package:tsp/screens/driver/about_company_screen.dart';
import 'package:tsp/screens/driver/driver_document/documentVerification_Stage.dart';

import 'package:tsp/screens/driver/driver_dashboard/driver_dashboard.dart';
import 'package:tsp/screens/driver/driver_help_issue_screen.dart';
import 'package:tsp/screens/driver/driver_liveloaction/driver_live_location.dart';
import 'package:tsp/screens/driver/driver_main_screen.dart';
import 'package:tsp/screens/driver/driver_profile_screen.dart';

import 'package:tsp/screens/driver/driver_upload_status_screen.dart';
import 'package:tsp/services/bluetooth_service.dart';
import 'package:tsp/services/scan_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor:
            const Color(0xFFFF5722), // Orange primary color from memory
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFFF5722),
          secondary: const Color(0xFFFF5722),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFFF5722),
        colorScheme:
            ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
          primary: const Color(0xFFFF5722),
          secondary: const Color(0xFFFF5722),
          background: Colors.black,
          surface: Colors.grey[900],
        ),
      ),
      themeMode: ThemeMode.system, // This will follow system theme
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RoleSelectionScreen(),
          ),
        ),
      ),
    );
  }
}
