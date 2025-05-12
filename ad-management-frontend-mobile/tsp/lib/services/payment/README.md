# RazorPay Integration for TSP Ad Management

This directory contains the frontend implementation for RazorPay payment gateway integration in the TSP Ad Management application.

## Credentials

Test credentials are configured:

- **API Key ID**: `rzp_test_hxp0wE0y7KdXKr`
- **Secret Key**: `lMKoka60gNReCR0HVjvRF9UC` (Only to be used in backend)

## File Structure

- `razorpay_service.dart` - Core service for handling RazorPay SDK integration
- `payment_manager.dart` - Manager class with payment flow logic and callbacks
- `payment_api_service.dart` - Service for making API calls to the backend payment endpoints

## Models

- `models/payment/razorpay_order.dart` - Model for RazorPay order data

## UI Components

- `screens/company/company_launch_ad_campain/campaign_preview/components/razorpay_payment_dialog.dart` - Dialog for handling payment UI flow

## How to Use

### 1. Initialize Payment in a Screen

```dart
// Import the necessary files
import 'package:tsp/services/payment/payment_manager.dart';
import 'package:tsp/screens/company/company_launch_ad_campain/campaign_preview/components/razorpay_payment_dialog.dart';

// Show payment dialog when user wants to pay
void initiatePayment() {
  showDialog(
    context: context,
    builder: (context) => RazorPaymentDialog(
      campaignDetails: campaignDetails,
      isDarkMode: isDarkMode,
      orangeColor: const Color(0xFFFF5722),
      totalAmount: totalAmount,
      // Optional: Add user details from your user profile
      // userEmail: currentUser.email,
      // userPhone: currentUser.phone,
      // userName: currentUser.name,
    ),
  );
}
```

### 2. Backend Integration

You'll need to implement these endpoints in your Node.js/Express backend:

- `POST /api/payment/create-order` - Create a RazorPay order
- `POST /api/payment/verify` - Verify a payment after completion
- `POST /api/campaigns/payment` - Save campaign payment information

## Android/iOS Configuration

### Android

For Android, add the following to your `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        // Add this line
        multiDexEnabled true
    }
}
```

### iOS

For iOS, the minimum deployment target should be iOS 10.0 or higher in your `ios/Podfile`:

```ruby
platform :ios, '10.0'
```

## Testing

Use test card details:
- Card Number: 4111 1111 1111 1111
- Expiry: Any future date
- CVV: Any 3 digits
- Name: Any name

## Important Notes

1. Remember to update the API endpoints in `payment_api_service.dart` with your actual backend URLs.
2. Do not use Secret Key in the frontend code - it should only be used in your backend.
3. In production, get user email, phone, and name from your user profile/auth system.
