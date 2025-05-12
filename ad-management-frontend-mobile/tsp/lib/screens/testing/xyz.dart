import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayTestScreen extends StatefulWidget {
  const RazorPayTestScreen({Key? key}) : super(key: key);

  @override
  State<RazorPayTestScreen> createState() => _RazorPayTestScreenState();
}

class _RazorPayTestScreenState extends State<RazorPayTestScreen> {
  // Create instance
  final Razorpay _razorpay = Razorpay();
  bool _isLoading = false;
  String _message = '';
  
  @override
  void initState() {
    super.initState();
    
    // Register event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      setState(() {
        _message = 'Success: ${response.paymentId}';
        _isLoading = false;
      });
      debugPrint('Payment Success: ${response.paymentId}');
    });
    
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
      setState(() {
        _message = 'Error: ${response.code} - ${response.message}';
        _isLoading = false;
      });
      debugPrint('Payment Error: ${response.code} - ${response.message}');
    });
    
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
      setState(() {
        _message = 'External Wallet: ${response.walletName}';
        _isLoading = false;
      });
      debugPrint('External Wallet: ${response.walletName}');
    });
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clear all listeners
    super.dispose();
  }

  // Simple test payment
  void _makeTestPayment() {
    setState(() {
      _isLoading = true;
      _message = 'Starting payment...';
    });
    
    debugPrint('Starting payment process');
    
    // Test options
    var options = {
      'key': 'rzp_test_hxp0wE0y7KdXKr',
      'amount': 500, // ₹5 in paise
      'name': 'TSP Test',
      'description': 'Test Payment',
      'prefill': {
        'contact': '9876543210',
        'email': 'test@example.com',
      },
    };
    
    try {
      debugPrint('Opening Razorpay with options: $options');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Exception: $e');
      setState(() {
        _message = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orangeColor = const Color(0xFFFF5722);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('RazorPay Test'),
        backgroundColor: orangeColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Simple RazorPay Test',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _isLoading
                ? const CircularProgressIndicator(color: Color(0xFFFF5722))
                : ElevatedButton(
                    onPressed: _makeTestPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text('Pay ₹5', style: TextStyle(fontSize: 18)),
                  ),
              if (_message.isNotEmpty) ...[  
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: _message.contains('Error') ? Colors.red[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    _message,
                    style: TextStyle(
                      color: _message.contains('Error') ? Colors.red[800] : Colors.green[800],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}