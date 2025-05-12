import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class DirectRazorPayTest extends StatefulWidget {
  const DirectRazorPayTest({Key? key}) : super(key: key);

  @override
  State<DirectRazorPayTest> createState() => _DirectRazorPayTestState();
}

class _DirectRazorPayTestState extends State<DirectRazorPayTest> {
  // Create Razorpay instance
  late Razorpay _razorpay;
  String _status = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize Razorpay
    _razorpay = Razorpay();
    
    // Set up payment callbacks
    _setupListeners();
    
    // Log that the screen is initialized
    debugPrint('DirectRazorPayTest initialized');
  }

  void _setupListeners() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    
    debugPrint('Razorpay listeners set up');
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('SUCCESS: Payment ID: ${response.paymentId}');
    setState(() {
      _status = 'Payment Successful - ID: ${response.paymentId}';
      _isLoading = false;
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('ERROR: ${response.code} - ${response.message}');
    setState(() {
      _status = 'Error: ${response.code} - ${response.message}';
      _isLoading = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('EXTERNAL WALLET: ${response.walletName}');
    setState(() {
      _status = 'External Wallet: ${response.walletName}';
      _isLoading = false;
    });
  }

  void _startDirectPayment() {
    debugPrint('Starting direct payment process');
    
    setState(() {
      _isLoading = true;
      _status = 'Initializing payment...';
    });

    try {
      var options = {
        'key': 'rzp_test_hxp0wE0y7KdXKr',
        'amount': 500, // ₹5 in paise
        'name': 'TSP Payment Test',
        'description': 'Simple Test Payment',
        'prefill': {
          'contact': '9876543210',
          'email': 'test@example.com',
        },
        'currency': 'INR',
      };

      debugPrint('Payment options: $options');
      
      // Open Razorpay checkout
      _razorpay.open(options);
      debugPrint('Razorpay checkout opened');
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct RazorPay Test'),
        backgroundColor: const Color(0xFFFF5722),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.payment,
                color: Color(0xFFFF5722),
                size: 64,
              ),
              const SizedBox(height: 20),
              const Text(
                'Direct RazorPay Integration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'This is a simple test with minimal code',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator(
                      color: Color(0xFFFF5722),
                    )
                  : ElevatedButton(
                      onPressed: _startDirectPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5722),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Pay ₹5',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
              if (_status.isNotEmpty) ...[
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: _status.contains('Error')
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _status.contains('Error')
                          ? Colors.red.withOpacity(0.5)
                          : Colors.green.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    _status,
                    style: TextStyle(
                      color: _status.contains('Error')
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
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
