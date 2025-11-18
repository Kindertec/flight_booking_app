import '../entities/flight.dart';
import '../repositories/flight_repository.dart';

/// Use case for getting detailed information about a specific flight
class GetFlightDetails {
  final FlightRepository repository;

  GetFlightDetails(this.repository);

  /// Execute the use case with flight ID
  Future<Flight> call(String flightId) async {
    try {
      final flight = await repository.getFlightById(flightId);

      if (flight == null) {
        throw FlightNotFoundException('Flight with ID $flightId not found');
      }

      // Business logic: Validate flight data
      _validateFlightData(flight);

      return flight;
    } catch (e) {
      if (e is FlightNotFoundException) {
        rethrow;
      }
      throw FlightException('Failed to get flight details: ${e.toString()}');
    }
  }

  void _validateFlightData(Flight flight) {
    // Business rule: Ensure flight has valid time
    if (flight.arrivalTime.isBefore(flight.departureTime)) {
      throw InvalidFlightDataException(
          'Arrival time cannot be before departure time');
    }

    // Business rule: Ensure flight has positive price
    if (flight.totalFare <= 0) {
      throw InvalidFlightDataException('Flight price must be positive');
    }

    // Business rule: Ensure seats are available
    if (flight.seatsRemaining <= 0) {
      throw NoSeatsAvailableException('No seats available for this flight');
    }
  }
}

/// Custom exceptions
class FlightException implements Exception {
  final String message;
  FlightException(this.message);

  @override
  String toString() => message;
}

class FlightNotFoundException implements Exception {
  final String message;
  FlightNotFoundException(this.message);

  @override
  String toString() => message;
}

class InvalidFlightDataException implements Exception {
  final String message;
  InvalidFlightDataException(this.message);

  @override
  String toString() => message;
}

class NoSeatsAvailableException implements Exception {
  final String message;
  NoSeatsAvailableException(this.message);

  @override
  String toString() => message;
}
