import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tsp/models/payment/razorpay_order.dart';

/// Service for making payment-related API calls to the backend
class PaymentApiService {
  // Base URL for API calls - replace with your actual backend URL
  static const String baseUrl = 'http://3.110.135.112:5000/api';

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Add authorization token if needed
    // 'Authorization': 'Bearer $token',
  };

  /// Create a new order on the backend
  /// 
  /// Returns a RazorpayOrder with an order ID that can be used with the RazorPay SDK
  Future<RazorpayOrder?> createOrder({
    required int amount,
    required String receipt,
    required String currency,
    Map<String, dynamic>? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/create-order'),
        headers: _headers,
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'receipt': receipt,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return RazorpayOrder.fromJson(data['order']);
      } else {
        debugPrint('Error creating order: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception creating order: $e');
      return null;
    }
  }

  /// Verify payment after it's completed
  Future<bool> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/verify'),
        headers: _headers,
        body: jsonEncode({
          'razorpay_payment_id': paymentId,
          'razorpay_order_id': orderId,
          'razorpay_signature': signature,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['verified'] == true;
      } else {
        debugPrint('Error verifying payment: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception verifying payment: $e');
      return false;
    }
  }

  /// Save campaign payment information
  Future<bool> saveCampaignPayment({
    required String campaignId,
    required String paymentId,
    required String orderId,
    required int amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/campaigns/payment'),
        headers: _headers,
        body: jsonEncode({
          'campaignId': campaignId,
          'paymentId': paymentId,
          'orderId': orderId,
          'amount': amount,
          'status': 'completed',
          'paymentMethod': 'razorpay',
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Exception saving campaign payment: $e');
      return false;
    }
  }
}
