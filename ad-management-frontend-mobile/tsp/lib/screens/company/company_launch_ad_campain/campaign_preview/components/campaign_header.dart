import 'package:flutter/material.dart';
import 'grid_pattern.dart';

class CampaignHeader extends StatelessWidget {
  final Map<String, dynamic> campaignDetails;
  final VoidCallback onViewPoster;
  final bool hasPoster;
  final Color orangeColor;

  const CampaignHeader({
    Key? key,
    required this.campaignDetails,
    required this.onViewPoster,
    required this.hasPoster,
    required this.orangeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      width: double.infinity,
      height: screenSize.height * 0.25,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            orangeColor,
            orangeColor.withOpacity(0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: GridPattern(color: Colors.white),
            ),
          ),
          
          // Campaign title and info
          Positioned(
            left: 20,
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaignDetails['adTitle'] ?? 'New Campaign',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    campaignDetails['selectedPlan'] ?? 'No Plan Selected',
                    style: TextStyle(
                      color: orangeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Poster preview indicator if there's a poster
          if (hasPoster)
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: onViewPoster,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.image,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'View Poster',
                        style: TextStyle(
                          color: orangeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
