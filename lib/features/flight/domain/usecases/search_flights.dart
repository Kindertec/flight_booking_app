import '../entities/flight.dart';
import '../repositories/flight_repository.dart';

/// Use case for searching flights by route and date
class SearchFlights {
  final FlightRepository repository;

  SearchFlights(this.repository);

  /// Execute the use case with search parameters
  Future<List<Flight>> call(SearchParams params) async {
    try {
      // Validate search parameters
      _validateSearchParams(params);

      final flights = await repository.searchFlights(
        origin: params.origin,
        destination: params.destination,
        departureDate: params.departureDate,
      );

      // Business logic: Filter out flights that departed
      final validFlights = _filterExpiredFlights(flights);

      // Business logic: Sort by relevance (departure time)
      validFlights.sort((a, b) => a.departureTime.compareTo(b.departureTime));

      return validFlights;
    } catch (e) {
      throw FlightException('Failed to search flights: ${e.toString()}');
    }
  }

  void _validateSearchParams(SearchParams params) {
    if (params.origin.isEmpty) {
      throw InvalidSearchParamsException('Origin airport is required');
    }

    if (params.destination.isEmpty) {
      throw InvalidSearchParamsException('Destination airport is required');
    }

    if (params.origin == params.destination) {
      throw InvalidSearchParamsException(
          'Origin and destination cannot be the same');
    }

    if (params.departureDate != null &&
        params.departureDate!.isBefore(DateTime.now())) {
      throw InvalidSearchParamsException(
          'Departure date cannot be in the past');
    }
  }

  List<Flight> _filterExpiredFlights(List<Flight> flights) {
    final now = DateTime.now();
    return flights.where((flight) {
      return flight.departureTime.isAfter(now);
    }).toList();
  }
}

/// Search parameters value object
class SearchParams {
  final String origin;
  final String destination;
  final DateTime? departureDate;

  SearchParams({
    required this.origin,
    required this.destination,
    this.departureDate,
  });

  SearchParams copyWith({
    String? origin,
    String? destination,
    DateTime? departureDate,
  }) {
    return SearchParams(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
    );
  }
}

/// Custom exceptions
class FlightException implements Exception {
  final String message;
  FlightException(this.message);

  @override
  String toString() => message;
}

class InvalidSearchParamsException implements Exception {
  final String message;
  InvalidSearchParamsException(this.message);

  @override
  String toString() => message;
}
