import 'package:flutter/material.dart';

class DriverDetailCard extends StatelessWidget {
  final Map<String, dynamic> driver;

  const DriverDetailCard({Key? key, required this.driver}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primary.withOpacity(0.1),
                  child: Icon(Icons.person, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    driver['fullName'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.email, "Email", driver['email']),
            _buildInfoRow(
                context, Icons.phone, "Phone", driver['contactNumber']),
            _buildInfoRow(
              context,
              Icons.directions_car,
              "Vehicle",
              "${driver['vehicleNumber'] ?? 'N/A'} (${driver['vehicleType'] ?? 'N/A'})",
            ),
            _buildInfoRow(
                context, Icons.location_on, "Address", driver['address']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String? value,
  ) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 20),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}
