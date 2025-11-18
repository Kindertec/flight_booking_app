import 'package:equatable/equatable.dart';
import '../../domain/entities/enriched_flight.dart';
import '../../domain/usecases/filter_flights.dart';

abstract class FlightState extends Equatable {
  const FlightState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FlightInitial extends FlightState {
  const FlightInitial();
}

/// Loading state
class FlightLoading extends FlightState {
  const FlightLoading();
}

/// Loaded state with ENRICHED flights and filters
class FlightLoaded extends FlightState {
  final List<EnrichedFlight> allFlights;
  final List<EnrichedFlight> filteredFlights;
  final FilterParams filterParams;
  final double actualMinPrice;
  final double actualMaxPrice;

  const FlightLoaded({
    required this.allFlights,
    required this.filteredFlights,
    required this.filterParams,
    required this.actualMinPrice,
    required this.actualMaxPrice,
  });

  @override
  List<Object?> get props => [
        allFlights,
        filteredFlights,
        filterParams,
        actualMinPrice,
        actualMaxPrice,
      ];

  /// Get unique airlines
  List<String> get availableAirlines {
    return allFlights.map((f) => f.flight.airlineName).toSet().toList()..sort();
  }

  /// Get unique cabin classes
  List<String> get availableCabinClasses {
    return allFlights.map((f) => f.flight.cabinClass).toSet().toList()..sort();
  }

  /// Count active filters
  int get activeFiltersCount {
    int count = 0;
    if (filterParams.minPrice != null &&
        filterParams.minPrice! > actualMinPrice) {
      count++;
    }
    if (filterParams.maxPrice != null &&
        filterParams.maxPrice! < actualMaxPrice) {
      count++;
    }
    if (filterParams.airlineCodes != null &&
        filterParams.airlineCodes!.isNotEmpty) {
      count++;
    }
    if (filterParams.cabinClasses != null &&
        filterParams.cabinClasses!.isNotEmpty) {
      count++;
    }
    if (filterParams.nonStopOnly == true) count++;
    if (filterParams.refundableOnly == true) count++;
    return count;
  }

  /// Get selected airlines
  Set<String> get selectedAirlines {
    return filterParams.airlineCodes?.toSet() ?? {};
  }

  /// Get selected cabin classes
  Set<String> get selectedCabinClasses {
    return filterParams.cabinClasses?.toSet() ?? {};
  }

  /// Copy with new values
  FlightLoaded copyWith({
    List<EnrichedFlight>? allFlights,
    List<EnrichedFlight>? filteredFlights,
    FilterParams? filterParams,
    double? actualMinPrice,
    double? actualMaxPrice,
  }) {
    return FlightLoaded(
      allFlights: allFlights ?? this.allFlights,
      filteredFlights: filteredFlights ?? this.filteredFlights,
      filterParams: filterParams ?? this.filterParams,
      actualMinPrice: actualMinPrice ?? this.actualMinPrice,
      actualMaxPrice: actualMaxPrice ?? this.actualMaxPrice,
    );
  }
}

/// Error state
class FlightError extends FlightState {
  final String message;

  const FlightError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Flight detail loading state
class FlightDetailLoading extends FlightState {
  const FlightDetailLoading();
}

/// Flight detail loaded state (with ENRICHED flight)
class FlightDetailLoaded extends FlightState {
  final EnrichedFlight enrichedFlight;

  const FlightDetailLoaded(this.enrichedFlight);

  @override
  List<Object?> get props => [enrichedFlight];
}

/// Flight detail error state
class FlightDetailError extends FlightState {
  final String message;

  const FlightDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
