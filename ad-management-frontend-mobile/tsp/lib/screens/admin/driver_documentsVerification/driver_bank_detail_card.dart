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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bank Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Bank: $bankName"),
            Text("Branch: $branchName"),
            Text("IFSC Code: $ifscCode"),
            Text("Account Number: $accountNumber"),
          ],
        ),
      ),
    );
  }
}
