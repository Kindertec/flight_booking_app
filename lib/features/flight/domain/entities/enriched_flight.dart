import 'flight.dart';
import 'airline.dart';
import 'baggage_service.dart';

/// Pure domain entity - enriched flight with additional reference data
class EnrichedFlight {
  final Flight flight;
  final Airline? airline;
  final List<BaggageService> availableBaggageServices;

  const EnrichedFlight({
    required this.flight,
    this.airline,
    this.availableBaggageServices = const [],
  });

  /// Get airline name (with fallback to flight's airline name)
  String get airlineName => airline?.name ?? flight.airlineName;

  /// Get airline full name (alias for consistency)
  String get airlineFullName => airlineName;

  /// Get airline logo URL
  String? get airlineLogoUrl => airline?.logoUrl;

  /// Get airline logo (alias for backward compatibility)
  String? get airlineLogo => airlineLogoUrl;

  /// Check if airline details are available
  bool get hasAirlineDetails => airline != null;

  /// Check if baggage options are available
  bool get hasBaggageServices => availableBaggageServices.isNotEmpty;

  /// Check if baggage options are available (alias for backward compatibility)
  bool get hasBaggageOptions => hasBaggageServices;

  /// Get available baggage options (alias for backward compatibility)
  List<BaggageService> get availableBaggageOptions => availableBaggageServices;

  /// Get cheapest baggage option
  BaggageService? get cheapestBaggageService {
    if (!hasBaggageServices) return null;

    return availableBaggageServices.reduce(
      (current, next) => current.price < next.price ? current : next,
    );
  }

  /// Get baggage services by weight range
  List<BaggageService> getBaggageServicesByWeight({
    int? minWeight,
    int? maxWeight,
  }) {
    if (!hasBaggageServices) return [];

    return availableBaggageServices.where((service) {
      if (minWeight != null && service.weightInKg < minWeight) return false;
      if (maxWeight != null && service.weightInKg > maxWeight) return false;
      return true;
    }).toList();
  }

  /// Calculate total cost with baggage
  double calculateTotalWithBaggage(
      BaggageService baggageService, int quantity) {
    return flight.totalFare + baggageService.calculateCost(quantity);
  }

  /// Copy with new values
  EnrichedFlight copyWith({
    Flight? flight,
    Airline? airline,
    List<BaggageService>? availableBaggageServices,
  }) {
    return EnrichedFlight(
      flight: flight ?? this.flight,
      airline: airline ?? this.airline,
      availableBaggageServices:
          availableBaggageServices ?? this.availableBaggageServices,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnrichedFlight && other.flight == flight;
  }

  @override
  int get hashCode => flight.hashCode;
}
