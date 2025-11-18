class BaggageService {
  final String id;
  final String description;
  final int weightInKg;
  final int numberOfBags;
  final double price;
  final String currency;
  final String checkInType;
  final int minQuantity;
  final int maxQuantity;
  final bool isMandatory;

  const BaggageService({
    required this.id,
    required this.description,
    required this.weightInKg,
    required this.numberOfBags,
    required this.price,
    required this.currency,
    required this.checkInType,
    required this.minQuantity,
    required this.maxQuantity,
    required this.isMandatory,
  });

  /// Calculate cost for multiple items
  double calculateCost(int quantity) {
    return price * quantity;
  }

  /// Format price for display
  String get formattedPrice => '$currency ${price.toStringAsFixed(2)}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaggageService && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
