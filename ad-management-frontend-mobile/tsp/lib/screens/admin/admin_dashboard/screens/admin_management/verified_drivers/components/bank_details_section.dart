import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/driver_detail_model.dart';

class BankDetailsSection extends StatelessWidget {
  final BankDetails bankDetails;
  
  const BankDetailsSection({
    Key? key,
    required this.bankDetails,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance,
                  color: const Color(0xFFFF5722),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bank Details',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildBankInfo(
              icon: Icons.account_balance,
              title: 'Bank Name',
              value: bankDetails.bankName,
              color: Colors.blue,
            ),
            
            const SizedBox(height: 12),
            
            _buildBankInfo(
              icon: Icons.location_city,
              title: 'Branch Name',
              value: bankDetails.branchName,
              color: Colors.purple,
            ),
            
            const SizedBox(height: 12),
            
            _buildBankInfo(
              icon: Icons.confirmation_number,
              title: 'Account Number',
              value: _maskAccountNumber(bankDetails.accountNumber),
              color: Colors.green,
              isSecure: true,
            ),
            
            const SizedBox(height: 12),
            
            _buildBankInfo(
              icon: Icons.code,
              title: 'IFSC Code',
              value: bankDetails.ifscCode,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBankInfo({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isSecure = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Row(
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isSecure) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.visibility_off,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) {
      return accountNumber;
    }
    
    final lastFour = accountNumber.substring(accountNumber.length - 4);
    final maskedPart = '*' * (accountNumber.length - 4);
    return '$maskedPart$lastFour';
  }
}
