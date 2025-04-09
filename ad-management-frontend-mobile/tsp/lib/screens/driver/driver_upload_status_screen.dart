import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'driver_main_screen.dart';

class DriverUploadStatusScreen extends StatefulWidget {
  final String status;

  const DriverUploadStatusScreen({Key? key, this.status = 'Pending'})
      : super(key: key);

  @override
  State<DriverUploadStatusScreen> createState() =>
      _DriverUploadStatusScreenState();
}

class _DriverUploadStatusScreenState extends State<DriverUploadStatusScreen>
    with SingleTickerProviderStateMixin {
  late String _status;
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _confettiTimer;
  bool _showConfetti = false;

  // Colors
  static const Color primaryOrange = Color(0xFFFF6B00);
  static const Color textColor = Color(0xFF2C3E50);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  // Feedback
  String? _rejectionReason;
  final List<String> _feedbackItems = [
    'Advertisement not clearly visible',
    'Vehicle license plate not visible',
    'Poor image quality or lighting',
    'Advertisement placement incorrect'
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.status;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();

    // Simulate status change after 3 seconds (for demo purposes only)
    if (_status == 'Pending') {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _status = 'Approved';
            // Trigger confetti animation
            _triggerConfetti();
          });
        }
      });
    }

    // Set example rejection reason if status is Rejected
    if (_status == 'Rejected') {
      _rejectionReason = 'Poor image quality or lighting';
    }
  }

  void _triggerConfetti() {
    setState(() {
      _showConfetti = true;
    });
    _confettiTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showConfetti = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_status == 'Rejected')
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () => _showHelpDialog(),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ScaleTransition(
                  scale: _animation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildStatusCard(),
                      const SizedBox(height: 24),
                      _buildTimelineSection(),
                      const SizedBox(height: 24),
                      if (_status == 'Rejected') _buildFeedbackSection(),
                      const SizedBox(height: 32),
                      _buildActionButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _getStatusColor().withOpacity(0.8),
            _getStatusColor().withOpacity(0.6),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            if (_showConfetti) ..._buildConfetti(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusIcon(),
                const SizedBox(height: 16),
                Text(
                  'Advertisement Status',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _status,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConfetti() {
    // Simple confetti effect
    final random = DateTime.now().millisecondsSinceEpoch;
    final confetti = <Widget>[];

    for (int i = 0; i < 30; i++) {
      final left = (random + i * 10) % MediaQuery.of(context).size.width;
      final size = ((random + i) % 10) + 5.0;

      confetti.add(
        Positioned(
          left: left.toDouble(),
          top: (random + i * 20) % 180,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -20.0, end: 180.0),
            duration: Duration(milliseconds: 1000 + i * 100),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: child,
              );
            },
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Color(((random + i * 50) % 0xFFFFFF) | 0xFF000000),
                shape: i % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
              ),
            ),
          ),
        ),
      );
    }

    return confetti;
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _getStatusTitle(),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _getStatusMessage(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Icon(
                _getStatusIcon(),
                size: 20,
                color: _getStatusColor(),
              ),
              Text(
                _getStatusInfo(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history,
                  color: primaryOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Status Timeline',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTimelineItem(
            'Submitted',
            'Your advertisement proof has been submitted',
            Icons.cloud_upload,
            true,
            DateTime.now().subtract(const Duration(minutes: 5)),
          ),
          _buildTimelineConnector(true),
          _buildTimelineItem(
            'Under Review',
            'Our team is reviewing your submission',
            Icons.pending_actions,
            _status != 'Pending',
            _status != 'Pending'
                ? DateTime.now().subtract(const Duration(minutes: 3))
                : null,
          ),
          _buildTimelineConnector(
              _status == 'Approved' || _status == 'Rejected'),
          _buildTimelineItem(
            _status == 'Rejected' ? 'Rejected' : 'Approved',
            _status == 'Rejected'
                ? 'Your submission was rejected'
                : 'Your submission was approved',
            _status == 'Rejected' ? Icons.cancel : Icons.check_circle,
            _status == 'Approved' || _status == 'Rejected',
            _status == 'Approved' || _status == 'Rejected'
                ? DateTime.now().subtract(const Duration(minutes: 1))
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, IconData icon,
      bool isCompleted, DateTime? timestamp) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? _getStatusColor() : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? textColor : Colors.grey[500],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isCompleted ? Colors.grey[700] : Colors.grey[500],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              if (timestamp != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _formatTimestamp(timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector(bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      width: 2,
      height: 40,
      color: isCompleted ? _getStatusColor() : Colors.grey.shade300,
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.feedback,
                  color: Colors.red.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Feedback from Reviewer',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason for Rejection:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _rejectionReason ?? 'Please submit a clearer image',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'How to fix this:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFixItem('Make sure the lighting is adequate'),
                const SizedBox(height: 6),
                _buildFixItem('Take the photo from a better angle'),
                const SizedBox(height: 6),
                _buildFixItem('Ensure the advertisement is completely visible'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          color: Colors.green.shade400,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: textColor,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    switch (_status) {
      case 'Approved':
        return _buildApprovedButton();
      case 'Rejected':
        return _buildRejectedButton();
      default:
        return _buildPendingButton();
    }
  }

  Widget _buildApprovedButton() {
    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to DriverMainScreen and clear navigation stack
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const DriverMainScreen(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Continue to Dashboard',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            // Download certificate or show details
            _showCertificateDialog();
          },
          icon: const Icon(
            Icons.download,
            color: primaryOrange,
            size: 18,
          ),
          label: Text(
            'Download Verification Certificate',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: primaryOrange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingButton() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This usually takes 2-24 hours',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.orange.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey.shade600,
                    ),
                  ),
                ),
                Text(
                  'Waiting for Approval',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: primaryOrange,
            size: 18,
          ),
          label: Text(
            'Back to Upload Screen',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: primaryOrange,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRejectedButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Upload New Proof',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            // Open a support chat
            _showSupportDialog();
          },
          icon: const Icon(
            Icons.support_agent,
            color: primaryOrange,
            size: 18,
          ),
          label: Text(
            'Contact Support',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: primaryOrange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon() {
    switch (_status) {
      case 'Approved':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            size: 50,
            color: Colors.white,
          ),
        );
      case 'Rejected':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cancel,
            size: 50,
            color: Colors.white,
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.access_time,
            size: 50,
            color: Colors.white,
          ),
        );
    }
  }

  IconData _getStatusIcon() {
    switch (_status) {
      case 'Approved':
        return Icons.verified;
      case 'Rejected':
        return Icons.dangerous;
      default:
        return Icons.hourglass_top;
    }
  }

  Color _getStatusColor() {
    switch (_status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red.shade600;
      default:
        return Colors.orange;
    }
  }

  String _getStatusTitle() {
    switch (_status) {
      case 'Approved':
        return 'Advertisement Proof Approved!';
      case 'Rejected':
        return 'Advertisement Proof Rejected';
      default:
        return 'Advertisement Proof Under Review';
    }
  }

  String _getStatusMessage() {
    switch (_status) {
      case 'Approved':
        return 'Your advertisement proof has been verified and approved by our team. You can now continue to your dashboard.';
      case 'Rejected':
        return 'Your advertisement proof was rejected. Please read the feedback below and upload a new proof that meets the requirements.';
      default:
        return 'Your advertisement proof is being reviewed by our verification team. We\'ll notify you once the process is complete.';
    }
  }

  String _getStatusInfo() {
    switch (_status) {
      case 'Approved':
        return 'Approved on ${_formatDate(DateTime.now())}';
      case 'Rejected':
        return 'Rejected on ${_formatDate(DateTime.now())}';
      default:
        return 'Estimated completion: 2-24 hours';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    }
  }

  void _showCertificateDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified,
                    color: Colors.green.shade600,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Verification Certificate',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildCertificateItem('Verification ID',
                          'VER-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8)}'),
                      const SizedBox(height: 8),
                      _buildCertificateItem(
                          'Approved Date', _formatDate(DateTime.now())),
                      const SizedBox(height: 8),
                      _buildCertificateItem('Status', 'Approved & Verified'),
                      const SizedBox(height: 8),
                      _buildCertificateItem('Validator', 'TSP Admin Team'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Here you would add the actual download functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Certificate downloaded successfully',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: Text(
                      'Download Certificate',
                      style: GoogleFonts.poppins(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: primaryOrange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Help & Guidelines',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'How to take a good photo:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildHelpItem('Ensure good lighting - avoid shadows'),
                _buildHelpItem(
                    'Take photo from a distance showing the entire advertisement'),
                _buildHelpItem(
                    'Make sure the vehicle license plate is visible'),
                _buildHelpItem('Avoid blurry images - keep the camera steady'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Got it',
                      style: GoogleFonts.poppins(
                        color: primaryOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade400,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: textColor,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.support_agent,
                    color: primaryOrange,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Contact Support',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Our team is here to help you resolve any issues with your advertisement proof.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildSupportOption(
                  'Chat with Support',
                  Icons.chat_bubble_outline,
                  'Start a conversation with our support team',
                ),
                const SizedBox(height: 12),
                _buildSupportOption(
                  'Call Support',
                  Icons.phone,
                  'Call our support hotline',
                ),
                const SizedBox(height: 12),
                _buildSupportOption(
                  'Email Support',
                  Icons.email_outlined,
                  'Send us an email with your query',
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      color: primaryOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportOption(String title, IconData icon, String subtitle) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Here you would implement the actual support functionality
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connecting to $title...',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: primaryOrange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: primaryOrange,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
