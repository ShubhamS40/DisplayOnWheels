# Onboarding Screens for Litvertise

This directory contains the implementation of 4 onboarding screens for the Litvertise mobile advertisement management app.

## Images Required

You'll need to create the following images and place them in the assets/images/onboarding directory:

1. `welcome_car.png` - An illustration of a car with a megaphone or billboard representing mobile advertisement
2. `display_ads.png` - An illustration of a company uploading an ad for a taxi
3. `tracking.png` - An illustration of a map with a car and a live GPS route
4. `driver.png` - An illustration of a driver placing an ad poster on their car

The images should follow a clean, modern design style with the primary color #E89C08.

## Integration

To integrate these screens into your app, you need to:

1. Add the OnboardingScreen to your app's navigation
2. Pass a callback function to handle what happens when onboarding is complete

Example:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OnboardingScreen(
      onComplete: () {
        // Navigate to your main app or login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => YourMainScreen()),
        );
      },
    ),
  ),
);
```

The onboarding flow automatically handles navigation between the screens and provides skip options.
