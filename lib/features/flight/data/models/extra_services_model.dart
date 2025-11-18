class ExtraServicesResponse {
  final bool success;
  final List<BaggageServiceModel> dynamicBaggage;

  ExtraServicesResponse({
    required this.success,
    required this.dynamicBaggage,
  });

  factory ExtraServicesResponse.fromJson(Map<String, dynamic> json) {
    final result = json['ExtraServicesResponse']['ExtraServicesResult'];
    final data = result['ExtraServicesData'];

    return ExtraServicesResponse(
      success: result['success'] == true,
      dynamicBaggage: (data['DynamicBaggage'] as List)
          .map((item) => BaggageServiceModel.fromJson(item))
          .toList(),
    );
  }
}

class BaggageServiceModel {
  final String behavior; // PER_PAX_OUTBOUND, PER_PAX_INBOUND
  final bool isMultiSelect;
  final List<List<ServiceOption>> services;

  BaggageServiceModel({
    required this.behavior,
    required this.isMultiSelect,
    required this.services,
  });

  factory BaggageServiceModel.fromJson(Map<String, dynamic> json) {
    return BaggageServiceModel(
      behavior: json['Behavior'],
      isMultiSelect: json['IsMultiSelect'],
      services: (json['Services'] as List)
          .map((serviceList) => (serviceList as List)
              .map((service) => ServiceOption.fromJson(service))
              .toList())
          .toList(),
    );
  }

  // Get flattened list of all service options
  List<ServiceOption> get allOptions {
    return services.expand((list) => list).toList();
  }
}

class ServiceOption {
  final String serviceId;
  final String checkInType;
  final String description;
  final String fareDescription;
  final bool isMandatory;
  final int minimumQuantity;
  final int maximumQuantity;
  final ServiceCost serviceCost;

  ServiceOption({
    required this.serviceId,
    required this.checkInType,
    required this.description,
    required this.fareDescription,
    required this.isMandatory,
    required this.minimumQuantity,
    required this.maximumQuantity,
    required this.serviceCost,
  });

  factory ServiceOption.fromJson(Map<String, dynamic> json) {
    return ServiceOption(
      serviceId: json['ServiceId'],
      checkInType: json['CheckInType'],
      description: json['Description'],
      fareDescription: json['FareDescription'],
      isMandatory: json['IsMandatory'],
      minimumQuantity: json['MinimumQuantity'],
      maximumQuantity: json['MaximumQuantity'],
      serviceCost: ServiceCost.fromJson(json['ServiceCost']),
    );
  }

  // Parse weight from description (e.g., "1 bags - 15Kg" -> 15)
  int? get weightInKg {
    final match = RegExp(r'(\d+)Kg').firstMatch(description);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  // Get number of bags from description
  int? get numberOfBags {
    final match = RegExp(r'(\d+)\s+bags?').firstMatch(description);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }
}

class ServiceCost {
  final String currencyCode;
  final double amount;
  final int decimalPlaces;

  ServiceCost({
    required this.currencyCode,
    required this.amount,
    required this.decimalPlaces,
  });

  factory ServiceCost.fromJson(Map<String, dynamic> json) {
    return ServiceCost(
      currencyCode: json['CurrencyCode'],
      amount: double.parse(json['Amount']),
      decimalPlaces: int.parse(json['DecimalPlaces']),
    );
  }

  String get formattedAmount {
    return '${currencyCode} ${amount.toStringAsFixed(decimalPlaces)}';
  }
}
