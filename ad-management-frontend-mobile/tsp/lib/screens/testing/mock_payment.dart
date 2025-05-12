import 'dart:async';
import 'package:flutter/material.dart';

class MockPaymentScreen extends StatefulWidget {
  const MockPaymentScreen({Key? key}) : super(key: key);

  @override
  State<MockPaymentScreen> createState() => _MockPaymentScreenState();
}

class _MockPaymentScreenState extends State<MockPaymentScreen> {
  bool _showPaymentSheet = false;
  bool _paymentProcessing = false;
  bool _paymentSuccess = false;
  
  @override
  Widget build(BuildContext context) {
    final orangeColor = const Color(0xFFFF5722);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Payment Demo'),
        backgroundColor: orangeColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Main content
          Center(
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
                    'Payment Demonstration',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Since RazorPay is having compatibility issues, this is a mock demonstration of how the payment flow would work',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showPaymentSheet = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeColor,
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
                ],
              ),
            ),
          ),
          
          // Payment sheet overlay
          if (_showPaymentSheet)
            _buildPaymentSheet(context, orangeColor),
            
          // Success overlay
          if (_paymentSuccess)
            _buildSuccessOverlay(context, orangeColor),
        ],
      ),
    );
  }
  
  Widget _buildPaymentSheet(BuildContext context, Color orangeColor) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RazorPay',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: orangeColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _showPaymentSheet = false;
                        });
                      },
                      color: Colors.grey,
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'Payment Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 15),
                _buildDetailRow('Amount', '₹5.00'),
                _buildDetailRow('Description', 'Test Payment'),
                _buildDetailRow('Order ID', 'order_mock123456789'),
                const SizedBox(height: 20),
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.credit_card, color: orangeColor),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Credit/Debit Card',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('XXXX XXXX XXXX 1111', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _paymentProcessing 
                      ? null 
                      : () {
                          setState(() {
                            _paymentProcessing = true;
                          });
                          
                          // Simulate payment processing
                          Timer(const Duration(seconds: 2), () {
                            setState(() {
                              _showPaymentSheet = false;
                              _paymentProcessing = false;
                              _paymentSuccess = true;
                            });
                            
                            // Automatically dismiss success screen after 3 seconds
                            Timer(const Duration(seconds: 3), () {
                              if (mounted) {
                                setState(() {
                                  _paymentSuccess = false;
                                });
                              }
                            });
                          });
                        },
                    child: _paymentProcessing
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Pay Securely', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 15),
                const Center(
                  child: Text(
                    'Secured by RazorPay',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSuccessOverlay(BuildContext context, Color orangeColor) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Transaction ID: MOCK123456789',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Amount Paid: ₹5.00',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      setState(() {
                        _paymentSuccess = false;
                      });
                    },
                    child: const Text('Done', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
