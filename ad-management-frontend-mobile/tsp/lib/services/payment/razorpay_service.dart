import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Service class for handling Razorpay payment gateway integration
class RazorpayService {
  // RazorPay Test Credentials
  static const String razorpayKeyId = 'rzp_test_hxp0wE0y7KdXKr';
  // Secret key should only be used on the server side, not in the frontend

  final Razorpay _razorpay = Razorpay();

  // Callback functions
  final Function(PaymentSuccessResponse) onPaymentSuccess;
  final Function(PaymentFailureResponse) onPaymentFailure;
  final Function(ExternalWalletResponse) onExternalWallet;

  RazorpayService({
    required this.onPaymentSuccess,
    required this.onPaymentFailure,
    required this.onExternalWallet,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onPaymentFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  /// Start the payment process with RazorPay
  ///
  /// [amount] should be in paise (e.g. Rs 100 = 10000 paise)
  /// [description] payment description
  /// [name] customer name
  /// [email] customer email
  /// [contact] customer contact number
  /// [orderId] optional order ID if generated from backend
  void startPayment({
    required int amount,
    required String description,
    required String name,
    required String email,
    required String contact,
    String? orderId,
    String? theme,
  }) {
    debugPrint('Starting RazorPay payment flow with amount: $amount');

    var options = {
      'key': razorpayKeyId,
      'amount': amount, // in paise
      'name': name,
      'description': description,
      'timeout': 300, // in seconds
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'external': {
        'wallets': ['paytm']
      },
      'theme': {
        'color': '#FF5722', // Orange color matching TSP theme
      }
    };

    // Add order ID if available
    if (orderId != null) {
      options['order_id'] = orderId;
    }

    try {
      debugPrint('Opening RazorPay with options: $options');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening RazorPay: $e');
      // If there's an error, call the failure callback directly
      onPaymentFailure(PaymentFailureResponse(
          0, // code
          'Failed to open RazorPay: $e', // message
          null // error
          ));
    }
  }

  /// Clear handlers when no longer needed
  void dispose() {
    _razorpay.clear();
  }
}
