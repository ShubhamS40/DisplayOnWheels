import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../providers/company_profile_provider.dart';
import '../../../../models/company_profile_model.dart';
import 'info_item.dart';

class CompanyInfoSection extends StatelessWidget {
  static const Color primaryOrange =
      Color(0xFFFF5722); // Using brand orange color
  static const Color textColor = Color(0xFF2C3E50);

  const CompanyInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<CompanyProfileProvider>(context);
    final basicDetails = profileProvider.basicDetails;
    final documentDetails = profileProvider.documentDetails;
    final companyInfo = documentDetails?.companyInfo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Information',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          InfoItem(
            icon: Icons.business,
            label: 'Business Name',
            value: basicDetails?.businessName ?? 'Loading...',
            color: primaryOrange,
            showAction: true,
            actionIcon: Icons.edit,
          ),
          const Divider(height: 24),
          InfoItem(
            icon: Icons.category,
            label: 'Business Type',
            value: basicDetails?.businessType ?? 'Loading...',
            color: Colors.purple,
            showAction: true,
            actionIcon: Icons.edit,
          ),
          const Divider(height: 24),
          InfoItem(
            icon: Icons.phone,
            label: 'Phone',
            value: basicDetails?.contactNumber ?? 'Loading...',
            color: Colors.blue,
            showAction: true,
            actionIcon: Icons.edit,
          ),
          const Divider(height: 24),
          InfoItem(
            icon: Icons.email,
            label: 'Email',
            value: basicDetails?.email ?? 'Loading...',
            color: Colors.green,
            showAction: true,
            actionIcon: Icons.edit,
          ),
          const Divider(height: 24),
          InfoItem(
            icon: Icons.location_on,
            label: 'Address',
            value: companyInfo?.address ?? 'Not provided',
            color: Colors.red,
            showAction: true,
            actionIcon: Icons.edit,
          ),
          const Divider(height: 24),
          InfoItem(
            icon: Icons.location_city,
            label: 'City, State',
            value: '${companyInfo?.city ?? 'Not provided'}, ${companyInfo?.state ?? ''}',
            color: Colors.teal,
            showAction: true,
            actionIcon: Icons.edit,
          ),
          const Divider(height: 24),
          InfoItem(
            icon: Icons.public,
            label: 'Country',
            value: companyInfo?.country ?? 'Not provided',
            color: Colors.indigo,
            showAction: true,
            actionIcon: Icons.edit,
          ),
          const Divider(height: 24),
          InfoItem(
            icon: Icons.pin_drop,
            label: 'Zip Code',
            value: companyInfo?.zipCode ?? 'Not provided',
            color: Colors.amber,
            showAction: true,
            actionIcon: Icons.edit,
          ),
          const Divider(height: 24),
          InfoItem(
            icon: Icons.account_balance_wallet,
            label: 'Wallet Balance',
            value: '₹${profileProvider.walletBalance.toStringAsFixed(2)}',
            color: Colors.green,
            showAction: true,
            actionIcon: Icons.add,
          ),
        ],
      ),
    );
  }
}
