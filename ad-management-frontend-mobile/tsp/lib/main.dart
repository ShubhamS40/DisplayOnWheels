import 'package:flutter/material.dart';
import 'package:tsp/screens/admin/admin_dashboard/admin_dashboard_screen.dart';
import 'package:tsp/screens/admin/company_documentsVerification/company_lists_not_verifiedDocuments.dart';
import 'package:tsp/screens/admin/driver_documentsVerification/driver_lists_not_verifiedDocumnets.dart';

import 'package:tsp/screens/auth/role_selection.dart';

import 'package:tsp/screens/company/company_document/company_upload_documents.dart';
import 'package:tsp/screens/company/company_document/company_verification_stage.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/ad_campaign_screen.dart';
import 'package:tsp/screens/driver/about_company_screen.dart';
import 'package:tsp/screens/driver/driver_document/documentVerification_Stage.dart';

import 'package:tsp/screens/driver/driver_dashboard.dart';
import 'package:tsp/screens/driver/driver_help_issue_screen.dart';
import 'package:tsp/screens/driver/driver_live_location.dart';
import 'package:tsp/screens/driver/driver_main_screen.dart';
import 'package:tsp/screens/driver/driver_profile_screen.dart';
import 'package:tsp/screens/driver/driver_upload_advertisement_proof.dart';
import 'package:tsp/screens/driver/driver_upload_status_screen.dart';
import 'package:tsp/services/bluetooth_service.dart';
import 'package:tsp/services/scan_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Light Theme
      darkTheme: ThemeData.dark(), // Dark Theme
      themeMode: ThemeMode.system, // Thisl will follow system theme
      home: RoleSelectionScreen(),
    );
  }
}
