import '../../domain/entities/baggage_service.dart';

class BaggageServiceModel extends BaggageService {
  const BaggageServiceModel({
    required super.id,
    required super.description,
    required super.weightInKg,
    required super.numberOfBags,
    required super.price,
    required super.currency,
    required super.checkInType,
    required super.minQuantity,
    required super.maxQuantity,
    required super.isMandatory,
  });

  factory BaggageServiceModel.fromJson(Map<String, dynamic> json) {
    // Parse weight from description (e.g., "1 bags - 15Kg" -> 15)
    final description = json['Description'] as String;
    final weightMatch = RegExp(r'(\d+)Kg').firstMatch(description);
    final weight = weightMatch != null ? int.parse(weightMatch.group(1)!) : 0;

    // Parse number of bags
    final bagsMatch = RegExp(r'(\d+)\s+bags?').firstMatch(description);
    final bags = bagsMatch != null ? int.parse(bagsMatch.group(1)!) : 1;

    final serviceCost = json['ServiceCost'] as Map<String, dynamic>;

    return BaggageServiceModel(
      id: json['ServiceId'] as String,
      description: description.trim(),
      weightInKg: weight,
      numberOfBags: bags,
      price: double.parse(serviceCost['Amount'] as String),
      currency: serviceCost['CurrencyCode'] as String,
      checkInType: json['CheckInType'] as String,
      minQuantity: json['MinimumQuantity'] as int,
      maxQuantity: json['MaximumQuantity'] as int,
      isMandatory: json['IsMandatory'] as bool,
    );
  }

  /// Convert to domain entity
  BaggageService toEntity() {
    return BaggageService(
      id: id,
      description: description,
      weightInKg: weightInKg,
      numberOfBags: numberOfBags,
      price: price,
      currency: currency,
      checkInType: checkInType,
      minQuantity: minQuantity,
      maxQuantity: maxQuantity,
      isMandatory: isMandatory,
    );
  }
}

/// Response wrapper for extra services
class ExtraServicesResponse {
  final bool success;
  final List<BaggageServiceGroup> baggageGroups;
  final List<dynamic> mealServices; // Empty in current data
  final List<dynamic> seatServices; // Empty in current data

  ExtraServicesResponse({
    required this.success,
    required this.baggageGroups,
    this.mealServices = const [],
    this.seatServices = const [],
  });

  factory ExtraServicesResponse.fromJson(Map<String, dynamic> json) {
    final result = json['ExtraServicesResponse']['ExtraServicesResult'];
    final data = result['ExtraServicesData'];

    return ExtraServicesResponse(
      success: result['success'] == true,
      baggageGroups: (data['DynamicBaggage'] as List)
          .map((item) => BaggageServiceGroup.fromJson(item))
          .toList(),
      mealServices: data['DynamicMeal'] ?? [],
      seatServices: data['DynamicSeat'] ?? [],
    );
  }

  /// Get all baggage services flattened
  List<BaggageServiceModel> getAllServices() {
    return baggageGroups
        .expand((group) => group.services)
        .expand((list) => list)
        .toList();
  }

  /// Get services by behavior
  List<BaggageServiceModel> getServicesByBehavior(String behavior) {
    try {
      final group = baggageGroups.firstWhere(
        (g) => g.behavior == behavior,
      );
      return group.services.expand((list) => list).toList();
    } catch (e) {
      // If behavior not found, return all services
      return getAllServices();
    }
  }
}

class BaggageServiceGroup {
  final String behavior;
  final bool isMultiSelect;
  final List<List<BaggageServiceModel>> services;

  BaggageServiceGroup({
    required this.behavior,
    required this.isMultiSelect,
    required this.services,
  });

  factory BaggageServiceGroup.fromJson(Map<String, dynamic> json) {
    return BaggageServiceGroup(
      behavior: json['Behavior'] as String,
      isMultiSelect: json['IsMultiSelect'] as bool,
      services: (json['Services'] as List)
          .map((serviceList) => (serviceList as List)
              .map((service) => BaggageServiceModel.fromJson(service))
              .toList())
          .toList(),
    );
  }
}
