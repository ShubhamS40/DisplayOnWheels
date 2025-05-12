// Recharge plan model to match the API response structure
class RechargePlan {
  final int id;
  final String title;
  final String subtitle;
  final String? note;
  final double price;
  final int durationDays;
  final List<String> features;
  final bool isRecommended;
  final bool isActive;
  final int? maxVehicles;

  RechargePlan({
    required this.id,
    required this.title,
    required this.subtitle,
    this.note,
    required this.price,
    required this.durationDays,
    required this.features,
    required this.isRecommended,
    required this.isActive,
    this.maxVehicles,
  });

  // Create a RechargePlan from JSON data
  factory RechargePlan.fromJson(Map<String, dynamic> json) {
    List<String> featuresFromJson = [];

    // Handle different ways features might come from the backend
    if (json['features'] != null) {
      if (json['features'] is List) {
        // Direct list of strings
        featuresFromJson = List<String>.from(json['features']);
      } else if (json['features'] is Map) {
        // Features may come as a map with nested objects
        featuresFromJson = List<String>.from(
            (json['features'] as Map).values.map((f) => f.toString()));
      }
    }

    return RechargePlan(
      id: json['id'],
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      note: json['note'],
      price: double.parse(json['price'].toString()),
      durationDays: json['durationDays'] ?? 0,
      features: featuresFromJson,
      isRecommended: json['isRecommended'] ?? false,
      isActive: json['isActive'] ?? true,
      maxVehicles: json['maxVehicles'],
    );
  }

  // Convert RechargePlan to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'note': note,
      'price': price,
      'durationDays': durationDays,
      'features': features,
      'isRecommended': isRecommended,
      'isActive': isActive,
      'maxVehicles': maxVehicles,
    };
  }
}
