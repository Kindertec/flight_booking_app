import '../entities/flight.dart';

/// Abstract repository interface - Domain layer doesn't know about implementation
/// This defines the contract that the data layer must implement
abstract class FlightRepository {
  /// Get all available flights
  Future<List<Flight>> getFlights();

  /// Get flights with filters applied
  Future<List<Flight>> getFilteredFlights({
    double? minPrice,
    double? maxPrice,
    List<String>? airlineCodes,
    List<String>? cabinClasses,
    bool? nonStopOnly,
    bool? refundableOnly,
  });

  /// Get a specific flight by ID
  Future<Flight?> getFlightById(String id);

  /// Search flights by route
  Future<List<Flight>> searchFlights({
    required String origin,
    required String destination,
    DateTime? departureDate,
  });

  /// Clears cache in refresh event in bloc
  void clearCache();
}
