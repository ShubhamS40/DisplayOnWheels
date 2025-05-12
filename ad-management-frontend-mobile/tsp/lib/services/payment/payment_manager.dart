import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tsp/services/payment/razorpay_service.dart';

/// Payment Manager for handling payment flows across the application
class PaymentManager {
  late RazorpayService _razorpayService;
  final Function(String paymentId) onPaymentComplete;
  final Function(String error) onPaymentError;
  
  PaymentManager({
    required this.onPaymentComplete,
    required this.onPaymentError,
  }) {
    _initializeRazorpay();
  }
  
  void _initializeRazorpay() {
    _razorpayService = RazorpayService(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentFailure: _handlePaymentFailure,
      onExternalWallet: _handleExternalWallet,
    );
  }
  
  /// Start campaign payment using RazorPay
  void startCampaignPayment({
    required String campaignName,
    required int totalAmount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? orderId,
  }) {
    // Convert amount to paise (Razorpay requires amount in paise)
    int amountInPaise = totalAmount * 100;
    
    _razorpayService.startPayment(
      amount: amountInPaise,
      description: 'Payment for Campaign: $campaignName',
      name: 'TSP Ad Management',
      email: customerEmail,
      contact: customerPhone,
      orderId: orderId,
    );
  }
  
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
    debugPrint('Order ID: ${response.orderId}');
    debugPrint('Signature: ${response.signature}');
    
    // In a real implementation, you would verify this payment with your backend
    // paymentApiService.verifyPayment(paymentId: response.paymentId!, orderId: response.orderId!, signature: response.signature!)
    
    // For now, just assume the payment was successful
    Future.delayed(const Duration(milliseconds: 100), () {
      // Small delay to ensure UI has time to catch up
      onPaymentComplete(response.paymentId ?? 'unknown');
    });
  }
  
  void _handlePaymentFailure(PaymentFailureResponse response) {
    debugPrint('Payment Failed: ${response.code} - ${response.message}');
    
    // Handle different error codes if needed
    String errorMessage;
    switch (response.code) {
      case Razorpay.PAYMENT_CANCELLED:
        errorMessage = 'Payment was cancelled';
        break;
      case Razorpay.NETWORK_ERROR:
        errorMessage = 'Network error occurred. Please check your connection';
        break;
      default:
        errorMessage = response.message ?? 'Payment failed. Please try again later';
    }
    
    onPaymentError(errorMessage);
  }
  
  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    // Handle the external wallet payment
  }
  
  /// Clean up when no longer needed
  void dispose() {
    _razorpayService.dispose();
  }
}
