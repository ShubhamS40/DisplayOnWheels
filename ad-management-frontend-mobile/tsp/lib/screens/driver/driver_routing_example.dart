import 'package:flutter/material.dart';
import 'driver_main_screen.dart';

/// This is an example showing how to use the driver navigation system
/// You can use this as a reference for implementing navigation in your app

class DriverRoutingExample extends StatelessWidget {
  const DriverRoutingExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Routing Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main way to access the driver area - through the main screen with tabs
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DriverMainScreen(),
                  ),
                );
              },
              child: const Text('Open Driver Main Screen (with tabs)'),
            ),
            const SizedBox(height: 20),
            const Text('Or navigate directly to individual screens:'),
            const SizedBox(height: 20),

            // Direct navigation to specific screens
            ElevatedButton(
              onPressed: () {
                DriverNavigation.navigateToProfile(context);
              },
              child: const Text('Go to Driver Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                DriverNavigation.navigateToHelp(context);
              },
              child: const Text('Go to Help & Issue Screen'),
            ),
            ElevatedButton(
              onPressed: () {
                DriverNavigation.navigateToCompanyInfo(context);
              },
              child: const Text('Go to About Company'),
            ),
            ElevatedButton(
              onPressed: () {
                DriverNavigation.navigateToUploadProof(context);
              },
              child: const Text('Go to Upload Ad Proof'),
            ),
            ElevatedButton(
              onPressed: () {
                DriverNavigation.navigateToLiveLocation(context);
              },
              child: const Text('Go to Live Location'),
            ),
          ],
        ),
      ),
    );
  }
}

/* HOW TO USE THE NAVIGATION SYSTEM

1. For main driver area with tabs:
   Navigator.of(context).push(
     MaterialPageRoute(builder: (context) => const DriverMainScreen()),
   );

2. For navigating to specific screens:
   Use the DriverNavigation helper class:
   
   DriverNavigation.navigateToProfile(context);
   DriverNavigation.navigateToHelp(context);
   DriverNavigation.navigateToCompanyInfo(context);
   DriverNavigation.navigateToUploadProof(context);
   DriverNavigation.navigateToLiveLocation(context);

3. For buttons in your driver screens that need to navigate to other screens:
   
   ElevatedButton(
     onPressed: () {
       DriverNavigation.navigateToCompanyInfo(context);
     },
     child: const Text('View Company Info'),
   ),

*/
