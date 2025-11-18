import '../entities/flight.dart';
import '../repositories/flight_repository.dart';

/// Use case for getting all flights
/// Encapsulates business logic and keeps it separate from UI
class GetFlights {
  final FlightRepository repository;

  GetFlights(this.repository);

  /// Execute the use case
  Future<List<Flight>> call() async {
    try {
      final flights = await repository.getFlights();

      // Business logic: Sort by price by default
      flights.sort((a, b) => a.totalFare.compareTo(b.totalFare));

      return flights;
    } catch (e) {
      throw FlightException('Failed to load flights: ${e.toString()}');
    }
  }
}

/// Custom exception for flight-related errors
class FlightException implements Exception {
  final String message;
  FlightException(this.message);

  @override
  String toString() => message;
}
