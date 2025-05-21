import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CampaignDetailsSection extends StatelessWidget {
  final String startDate;
  final String endDate;
  final String budget;
  final String location;
  final Function buildDetailItem;

  const CampaignDetailsSection({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.location,
    required this.buildDetailItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Campaign Details',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: buildDetailItem(
                  'Start Date',
                  startDate,
                  Icons.calendar_today,
                ) as Widget,
              ),
              Expanded(
                child: buildDetailItem(
                  'End Date',
                  endDate,
                  Icons.event_available,
                ) as Widget,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: buildDetailItem(
                  'Budget',
                  budget,
                  Icons.attach_money,
                ) as Widget,
              ),
              Expanded(
                child: buildDetailItem(
                  'Target Location',
                  location,
                  Icons.location_on,
                ) as Widget,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
