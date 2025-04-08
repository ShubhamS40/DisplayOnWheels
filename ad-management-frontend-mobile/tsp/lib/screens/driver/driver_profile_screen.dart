import 'package:flutter/material.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({Key? key}) : super(key: key);

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  String? _selectedReason;
  bool _showConfirmation = false;

  // Orange color palette
  static const Color primaryOrange = Color(0xFFFF7F00);
  static const Color lightOrange = Color(0xFFFFB266);
  static const Color darkOrange = Color(0xFFE66700);
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color(0xFFFFF8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        title: const Text(
          'Driver Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildDriverInfo(),
            _buildActiveCampaign(),
            _buildSurrenderSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: primaryOrange,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 70,
              color: primaryOrange,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'John Doe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_car, color: primaryOrange, size: 18),
                SizedBox(width: 5),
                Text(
                  'Toyota Corolla',
                  style: TextStyle(
                    color: darkOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfileAction(Icons.edit, 'Edit'),
              const SizedBox(width: 20),
              _buildProfileAction(Icons.settings, 'Settings'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: primaryOrange,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Card(
      margin: const EdgeInsets.all(15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: primaryOrange),
                SizedBox(width: 8),
                Text(
                  'Driver Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkOrange,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoItem(
              'Contact Details',
              'Phone: 123-456-7890, Email: johndoe@example.com',
              Icons.contact_phone,
            ),
            _buildInfoItem(
              'Vehicle Details',
              'Car Model: Toyota Corolla, Number Plate: XXX-1234, Year: 2020',
              Icons.directions_car,
            ),
            _buildInfoItem(
              'Bank Details',
              'State Bank of India : IFSC CODE SBIN00256, Account Number 42223210078',
              Icons.account_balance,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String details, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightOrange.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryOrange),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  details,
                  style: TextStyle(
                    color: Colors.black87.withOpacity(0.7),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCampaign() {
    return Card(
      margin: const EdgeInsets.all(15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.campaign, color: primaryOrange),
                SizedBox(width: 8),
                Text(
                  'Active Ad Campaign Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkOrange,
                  ),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildCampaignItem(
                          '🏢',
                          'Company Name',
                          'XYZ',
                        ),
                        const SizedBox(height: 15),
                        _buildCampaignItem(
                          '📅',
                          'Ad Duration',
                          '7 days left',
                          subtitle: 'Start Date - End Date',
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 100,
                    color: Colors.grey.withOpacity(0.3),
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🖼️ Current Poster',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: darkOrange,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Preview Image'),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Installed on Vehicle',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignItem(String emoji, String title, String value,
      {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$emoji $title',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkOrange,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87.withOpacity(0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildSurrenderSection() {
    return Card(
      margin: const EdgeInsets.all(15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assignment_return, color: primaryOrange),
                SizedBox(width: 8),
                Text(
                  'Surrender Ad Campaign',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkOrange,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Reason for Surrender',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            _buildReasonRadio('Personal Reason'),
            _buildReasonRadio('Vehicle Issue'),
            _buildReasonRadio('Campaign Completed'),
            _buildReasonRadio('Other'),
            const SizedBox(height: 15),
            if (_selectedReason != null && !_showConfirmation)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showConfirmation = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            if (_showConfirmation) _buildSurrenderConfirmation(),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonRadio(String reason) {
    return RadioListTile<String>(
      title: Text(reason),
      value: reason,
      groupValue: _selectedReason,
      activeColor: primaryOrange,
      contentPadding: EdgeInsets.zero,
      dense: true,
      onChanged: (value) {
        setState(() {
          _selectedReason = value;
          _showConfirmation = false;
        });
      },
    );
  }

  Widget _buildSurrenderConfirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Surrender Confirmation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to surrender the ad campaign? This action cannot be undone.',
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 20),
              const Text(
                'Poster Uninstallation Instructions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              const Text('Return Instructions'),
              Row(
                children: [
                  const Text('Pickup Location: '),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'View on Map',
                      style: TextStyle(color: primaryOrange),
                    ),
                  ),
                ],
              ),
              const Text('Return Date & Time Slot Selection'),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Status: Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please return the light frame and poster to the pickup location by the selected date and time.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _showConfirmation = false;
                });
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryOrange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: primaryOrange),
              ),
            ),
            const SizedBox(width: 15),
            ElevatedButton(
              onPressed: () {
                // Implement surrender action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              ),
              child: const Text('Confirm Surrender'),
            ),
          ],
        ),
      ],
    );
  }
}
