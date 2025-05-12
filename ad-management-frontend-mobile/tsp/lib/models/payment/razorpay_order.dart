class RazorpayOrder {
  final String id;
  final String currency;
  final int amount;
  final String status;
  final Map<String, dynamic>? notes;
  final String receipt;
  final int createdAt;

  RazorpayOrder({
    required this.id,
    required this.currency,
    required this.amount,
    required this.status,
    this.notes,
    required this.receipt,
    required this.createdAt,
  });

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) {
    return RazorpayOrder(
      id: json['id'],
      currency: json['currency'],
      amount: json['amount'],
      status: json['status'],
      notes: json['notes'],
      receipt: json['receipt'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currency': currency,
      'amount': amount,
      'status': status,
      'notes': notes,
      'receipt': receipt,
      'created_at': createdAt,
    };
  }
}
