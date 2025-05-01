import 'package:flutter/material.dart';

class DriverBankDetailCard extends StatelessWidget {
  final String bankName;
  final String branchName;
  final String ifscCode;
  final String accountNumber;

  const DriverBankDetailCard({
    Key? key,
    required this.bankName,
    required this.branchName,
    required this.ifscCode,
    required this.accountNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: primary),
                const SizedBox(width: 10),
                Text(
                  "Bank Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            _buildInfoRow(Icons.account_balance, "Bank", bankName),
            _buildInfoRow(Icons.location_city, "Branch", branchName),
            _buildInfoRow(Icons.confirmation_number, "IFSC Code", ifscCode),
            _buildInfoRow(Icons.numbers, "Account Number", accountNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
