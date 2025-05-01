import 'package:flutter/material.dart';

class CompanyDetailCard extends StatelessWidget {
  final Map<String, dynamic> companyData;

  const CompanyDetailCard({Key? key, required this.companyData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final company = companyData['company'] ?? {};
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Company Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Business Name', company['businessName'] ?? 'N/A'),
            _buildInfoRow('Business Type', company['businessType'] ?? 'N/A'),
            _buildInfoRow('Email', company['email'] ?? 'N/A'),
            _buildInfoRow('Contact Number', company['contactNumber'] ?? 'N/A'),
            
            // Display address information if available
            if (companyData.containsKey('companyAddress'))
              _buildAddressSection(companyData),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Address Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Address', data['companyAddress'] ?? 'N/A'),
        _buildInfoRow('City', data['companyCity'] ?? 'N/A'),
        _buildInfoRow('State', data['companyState'] ?? 'N/A'),
        _buildInfoRow('Country', data['companyCountry'] ?? 'N/A'),
        _buildInfoRow('Zip Code', data['companyZipCode'] ?? 'N/A'),
      ],
    );
  }
}
