import 'package:flutter/material.dart';

class DriverDetailCard extends StatelessWidget {
  final Map<String, dynamic> driver;

  const DriverDetailCard({Key? key, required this.driver}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(driver['fullName'] ?? 'Unknown',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Email: ${driver['email'] ?? 'N/A'}"),
            Text("Phone: ${driver['contactNumber'] ?? 'N/A'}"),
            Text(
                "Vehicle: ${driver['vehicleNumber'] ?? 'N/A'} (${driver['vehicleType'] ?? 'N/A'})"),
            Text("Address: ${driver['address'] ?? 'N/A'}"),
          ],
        ),
      ),
    );
  }
}
