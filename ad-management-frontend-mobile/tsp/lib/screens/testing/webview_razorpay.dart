import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewRazorPayScreen extends StatefulWidget {
  const WebViewRazorPayScreen({Key? key}) : super(key: key);

  @override
  State<WebViewRazorPayScreen> createState() => _WebViewRazorPayScreenState();
}

class _WebViewRazorPayScreenState extends State<WebViewRazorPayScreen> {
  bool _isLoading = true;
  late WebViewController _controller;
  final Color orangeColor = const Color(0xFFFF5722);
  bool _paymentComplete = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    // Create a controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('WebView: Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('WebView: Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });

            // Check for success redirect
            if (url.contains('razorpay-success') ||
                url.contains('payment_id=')) {
              _handlePaymentSuccess(url);
            }
          },
          onUrlChange: (UrlChange change) {
            debugPrint('WebView: URL changed to: ${change.url}');

            // Monitor for success or failure redirects
            if (change.url != null) {
              if (change.url!.contains('razorpay-success') ||
                  change.url!.contains('payment_id=')) {
                _handlePaymentSuccess(change.url!);
              }
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(_buildRazorPayHTML());
  }

  String _buildRazorPayHTML() {
    // Test payment amount - 5 rupees = 500 paise
    const amount = 500;
    const currency = 'INR';
    var receiptId =
        'receipt_' + DateTime.now().millisecondsSinceEpoch.toString();
    const keyId = 'rzp_test_hxp0wE0y7KdXKr';

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>RazorPay Test Payment</title>
        <style>
          body {
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            background-color: #121212;
            color: white;
          }
          .container {
            text-align: center;
            padding: 20px;
            max-width: 400px;
          }
          .btn {
            background-color: #FF5722;
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            margin-top: 20px;
          }
          .loader {
            border: 3px solid rgba(255, 87, 34, 0.3);
            border-radius: 50%;
            border-top: 3px solid #FF5722;
            width: 30px;
            height: 30px;
            animation: spin 1s linear infinite;
            margin: 20px auto;
            display: none;
          }
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
          h1 {
            font-size: 24px;
            margin-bottom: 10px;
          }
          p {
            color: #aaa;
            margin-bottom: 25px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>TSP Payment</h1>
          <p>Test payment of ₹5.00</p>
          <button id="pay-btn" class="btn">Pay with RazorPay</button>
          <div id="loader" class="loader"></div>
        </div>

        <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
        <script>
          document.getElementById('pay-btn').onclick = function() {
            document.getElementById('loader').style.display = 'block';
            document.getElementById('pay-btn').disabled = true;
            
            var options = {
              "key": "$keyId",
              "amount": "$amount",
              "currency": "$currency",
              "name": "TSP",
              "description": "Test Payment",
              "image": "https://i.ibb.co/T1VpHjj/icon.png",
              "handler": function (response){
                document.getElementById('loader').style.display = 'none';
                window.location.href = "razorpay-success://payment_id=" + response.razorpay_payment_id;
              },
              "prefill": {
                "name": "Test User",
                "email": "test@example.com",
                "contact": "9876543210"
              },
              "theme": {
                "color": "#FF5722"
              }
            };
            var rzp = new Razorpay(options);
            rzp.on('payment.failed', function (response){
              document.getElementById('loader').style.display = 'none';
              document.getElementById('pay-btn').disabled = false;
              alert(response.error.description);
            });
            rzp.open();
          };
        </script>
      </body>
      </html>
    ''';
  }

  void _handlePaymentSuccess(String url) {
    if (_paymentComplete) return; // Prevent multiple calls

    _paymentComplete = true;
    String paymentId = "";

    // Extract payment ID from URL
    if (url.contains('payment_id=')) {
      paymentId = url.split('payment_id=')[1];
      if (paymentId.contains('&')) {
        paymentId = paymentId.split('&')[0];
      }
    }

    debugPrint('Payment successful! ID: $paymentId');

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        content: Column(
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
            Text(
              'Transaction ID: ${paymentId.isNotEmpty ? paymentId : "RZP12345678"}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Amount Paid: ₹5.00',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: orangeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Done', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RazorPay Payment'),
        backgroundColor: orangeColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(orangeColor),
                    ),
                    const SizedBox(height: 20),
                    const Text('Loading RazorPay...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
