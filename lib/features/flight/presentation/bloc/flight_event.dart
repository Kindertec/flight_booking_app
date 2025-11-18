import 'package:equatable/equatable.dart';

abstract class FlightEvent extends Equatable {
  const FlightEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all flights
class LoadFlightsEvent extends FlightEvent {
  const LoadFlightsEvent();
}

/// Event to refresh flights (clear cache)
class RefreshFlightsEvent extends FlightEvent {
  const RefreshFlightsEvent();
}

/// Event to update price range filter
class UpdatePriceRangeEvent extends FlightEvent {
  final double minPrice;
  final double maxPrice;

  const UpdatePriceRangeEvent({
    required this.minPrice,
    required this.maxPrice,
  });

  @override
  List<Object?> get props => [minPrice, maxPrice];
}

/// Event to toggle airline filter
class ToggleAirlineEvent extends FlightEvent {
  final String airlineName;

  const ToggleAirlineEvent(this.airlineName);

  @override
  List<Object?> get props => [airlineName];
}

/// Event to toggle cabin class filter
class ToggleCabinClassEvent extends FlightEvent {
  final String cabinClass;

  const ToggleCabinClassEvent(this.cabinClass);

  @override
  List<Object?> get props => [cabinClass];
}

/// Event to toggle non-stop filter
class ToggleNonStopEvent extends FlightEvent {
  final bool nonStopOnly;

  const ToggleNonStopEvent(this.nonStopOnly);

  @override
  List<Object?> get props => [nonStopOnly];
}

/// Event to toggle refundable filter
class ToggleRefundableEvent extends FlightEvent {
  final bool refundableOnly;

  const ToggleRefundableEvent(this.refundableOnly);

  @override
  List<Object?> get props => [refundableOnly];
}

/// Event to update sorting
class UpdateSortingEvent extends FlightEvent {
  final String sortBy;

  const UpdateSortingEvent(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

/// Event to reset all filters
class ResetFiltersEvent extends FlightEvent {
  const ResetFiltersEvent();
}

/// Event to get flight details
class GetFlightDetailsEvent extends FlightEvent {
  final String flightId;

  const GetFlightDetailsEvent(this.flightId);

  @override
  List<Object?> get props => [flightId];
}

/// Event to search flights
class SearchFlightsEvent extends FlightEvent {
  final String origin;
  final String destination;
  final DateTime? departureDate;

  const SearchFlightsEvent({
    required this.origin,
    required this.destination,
    this.departureDate,
  });

  @override
  List<Object?> get props => [origin, destination, departureDate];
}
