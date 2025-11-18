import '../../domain/entities/flight.dart';
import '../../domain/repositories/flight_repository.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';

class FlightRepositoryImpl implements FlightRepository {
  final LocalDataSource localDataSource;
  final RemoteDataSource? remoteDataSource; // Optional for API calls

  // Cache for better performance
  List<Flight>? _cachedFlights;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  FlightRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

  @override
  Future<List<Flight>> getFlights() async {
    // Check cache first
    if (_isCacheValid()) {
      return _cachedFlights!;
    }

    try {
      // Try remote source first (if available)
      if (remoteDataSource != null) {
        try {
          final flights = await remoteDataSource!.getFlights();
          _updateCache(flights);
          return flights;
        } catch (e) {
          // Fall back to local data source if remote fails
          print('Remote fetch failed, using local data: $e');
        }
      }
      // Use local data source
      final flights = await localDataSource.getFlights();
      _updateCache(flights);
      return flights;
    } catch (e) {
      throw RepositoryException('Failed to fetch flights: ${e.toString()}');
    }
  }

  @override
  Future<List<Flight>> getFilteredFlights({
    double? minPrice,
    double? maxPrice,
    List<String>? airlineCodes,
    List<String>? cabinClasses,
    bool? nonStopOnly,
    bool? refundableOnly,
  }) async {
    try {
      final allFlights = await getFlights();

      return allFlights.where((flight) {
        if (minPrice != null && flight.totalFare < minPrice) return false;
        if (maxPrice != null && flight.totalFare > maxPrice) return false;

        if (airlineCodes != null &&
            airlineCodes.isNotEmpty &&
            !airlineCodes.contains(flight.airlineCode)) {
          return false;
        }

        if (cabinClasses != null &&
            cabinClasses.isNotEmpty &&
            !cabinClasses.contains(flight.cabinClass)) {
          return false;
        }

        if (nonStopOnly == true && flight.stops > 0) return false;
        if (refundableOnly == true && !flight.isRefundable) return false;

        return true;
      }).toList();
    } catch (e) {
      throw RepositoryException('Failed to filter flights: ${e.toString()}');
    }
  }

  @override
  Future<Flight?> getFlightById(String id) async {
    try {
      final flights = await getFlights();
      return flights.firstWhere(
        (flight) => flight.id == id,
        orElse: () => throw FlightNotFoundException('Flight not found'),
      );
    } catch (e) {
      if (e is FlightNotFoundException) rethrow;
      throw RepositoryException('Failed to get flight: ${e.toString()}');
    }
  }

  @override
  Future<List<Flight>> searchFlights({
    required String origin,
    required String destination,
    DateTime? departureDate,
  }) async {
    try {
      final flights = await getFlights();

      return flights.where((flight) {
        // Match origin and destination
        if (flight.departureAirport != origin) return false;
        if (flight.arrivalAirport != destination) return false;

        // Match date if provided
        if (departureDate != null) {
          final flightDate = DateTime(
            flight.departureTime.year,
            flight.departureTime.month,
            flight.departureTime.day,
          );
          final searchDate = DateTime(
            departureDate.year,
            departureDate.month,
            departureDate.day,
          );
          if (!flightDate.isAtSameMomentAs(searchDate)) return false;
        }

        return true;
      }).toList();
    } catch (e) {
      throw RepositoryException('Failed to search flights: ${e.toString()}');
    }
  }

  // Cache management
  bool _isCacheValid() {
    if (_cachedFlights == null || _cacheTime == null) {
      return false;
    }
    return DateTime.now().difference(_cacheTime!) < _cacheDuration;
  }

  void _updateCache(List<Flight> flights) {
    _cachedFlights = flights;
    _cacheTime = DateTime.now();
  }

  // Clear cache (useful for refresh)
  @override
  void clearCache() {
    _cachedFlights = null;
    _cacheTime = null;
  }
}

/// Custom exceptions
class RepositoryException implements Exception {
  final String message;
  RepositoryException(this.message);

  @override
  String toString() => message;
}

class FlightNotFoundException implements Exception {
  final String message;
  FlightNotFoundException(this.message);

  @override
  String toString() => message;
}
