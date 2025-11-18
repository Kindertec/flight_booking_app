import '../entities/flight.dart';
import '../repositories/flight_repository.dart';

/// Use case for filtering flights
/// Contains business logic for applying filters
class FilterFlights {
  final FlightRepository repository;

  FilterFlights(this.repository);

  /// Execute the use case with filter parameters
  Future<List<Flight>> call(FilterParams params) async {
    try {
      // Get all flights first
      final allFlights = await repository.getFlights();

      // Apply business rules and filters
      final filtered = allFlights.where((flight) {
        // Price range filter
        if (params.minPrice != null && flight.totalFare < params.minPrice!) {
          return false;
        }
        if (params.maxPrice != null && flight.totalFare > params.maxPrice!) {
          return false;
        }

        // Airline filter
        if (params.airlineCodes != null &&
            params.airlineCodes!.isNotEmpty &&
            !params.airlineCodes!.contains(flight.airlineCode)) {
          return false;
        }

        // Cabin class filter
        if (params.cabinClasses != null &&
            params.cabinClasses!.isNotEmpty &&
            !params.cabinClasses!.contains(flight.cabinClass)) {
          return false;
        }

        // Non-stop filter
        if (params.nonStopOnly == true && flight.stops > 0) {
          return false;
        }

        // Refundable filter
        if (params.refundableOnly == true && !flight.isRefundable) {
          return false;
        }

        return true;
      }).toList();

      // Apply sorting based on sort type
      _applySorting(filtered, params.sortBy);

      return filtered;
    } catch (e) {
      throw FlightException('Failed to filter flights: ${e.toString()}');
    }
  }

  void _applySorting(List<Flight> flights, SortType sortBy) {
    switch (sortBy) {
      case SortType.priceLowToHigh:
        flights.sort((a, b) => a.totalFare.compareTo(b.totalFare));
        break;
      case SortType.priceHighToLow:
        flights.sort((a, b) => b.totalFare.compareTo(a.totalFare));
        break;
      case SortType.duration:
        flights.sort((a, b) {
          final aDuration = int.parse(a.duration);
          final bDuration = int.parse(b.duration);
          return aDuration.compareTo(bDuration);
        });
        break;
      case SortType.departureTime:
        flights.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
    }
  }
}

/// Filter parameters value object
class FilterParams {
  final double? minPrice;
  final double? maxPrice;
  final List<String>? airlineCodes;
  final List<String>? cabinClasses;
  final bool? nonStopOnly;
  final bool? refundableOnly;
  final SortType sortBy;

  FilterParams({
    this.minPrice,
    this.maxPrice,
    this.airlineCodes,
    this.cabinClasses,
    this.nonStopOnly,
    this.refundableOnly,
    this.sortBy = SortType.priceLowToHigh,
  });

  FilterParams copyWith({
    double? minPrice,
    double? maxPrice,
    List<String>? airlineCodes,
    List<String>? cabinClasses,
    bool? nonStopOnly,
    bool? refundableOnly,
    SortType? sortBy,
  }) {
    return FilterParams(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      airlineCodes: airlineCodes ?? this.airlineCodes,
      cabinClasses: cabinClasses ?? this.cabinClasses,
      nonStopOnly: nonStopOnly ?? this.nonStopOnly,
      refundableOnly: refundableOnly ?? this.refundableOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

enum SortType {
  priceLowToHigh,
  priceHighToLow,
  duration,
  departureTime,
}

class FlightException implements Exception {
  final String message;
  FlightException(this.message);

  @override
  String toString() => message;
}
