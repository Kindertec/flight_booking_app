import 'package:flight_booking_app/features/flight/domain/usecases/clear_flight_cache.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_flights.dart';
import '../../domain/usecases/filter_flights.dart';
import '../../domain/usecases/get_flight_details.dart';
import '../../domain/usecases/search_flights.dart';
import '../../domain/usecases/enrich_flights.dart';
import 'flight_event.dart';
import 'flight_state.dart';

class FlightBloc extends Bloc<FlightEvent, FlightState> {
  final GetFlights getFlightsUseCase;
  final FilterFlights filterFlightsUseCase;
  final GetFlightDetails getFlightDetailsUseCase;
  final SearchFlights searchFlightsUseCase;
  final EnrichFlights enrichFlightsUseCase;
  final ClearFlightCache clearFlightCacheUseCase;

  // Store current filter params
  FilterParams _currentFilterParams = FilterParams(
    sortBy: SortType.priceLowToHigh,
  );

  FlightBloc({
    required this.getFlightsUseCase,
    required this.filterFlightsUseCase,
    required this.getFlightDetailsUseCase,
    required this.searchFlightsUseCase,
    required this.enrichFlightsUseCase,
    required this.clearFlightCacheUseCase,
  }) : super(const FlightInitial()) {
    // Register event handlers
    on<LoadFlightsEvent>(_onLoadFlights);
    on<RefreshFlightsEvent>(_onRefreshFlights);
    on<UpdatePriceRangeEvent>(_onUpdatePriceRange);
    on<ToggleAirlineEvent>(_onToggleAirline);
    on<ToggleCabinClassEvent>(_onToggleCabinClass);
    on<ToggleNonStopEvent>(_onToggleNonStop);
    on<ToggleRefundableEvent>(_onToggleRefundable);
    on<UpdateSortingEvent>(_onUpdateSorting);
    on<ResetFiltersEvent>(_onResetFilters);
    on<GetFlightDetailsEvent>(_onGetFlightDetails);
    on<SearchFlightsEvent>(_onSearchFlights);
  }

  /// Load all flights and enrich them
  Future<void> _onLoadFlights(
    LoadFlightsEvent event,
    Emitter<FlightState> emit,
  ) async {
    emit(const FlightLoading());

    try {
      // Get basic flights
      final flights = await getFlightsUseCase();

      // Enrich flights with reference data (airline details, baggage options)
      final enrichedFlights =
          await enrichFlightsUseCase.enrichMultiple(flights);

      // Calculate price range
      final minPrice = enrichedFlights.isEmpty
          ? 0.0
          : enrichedFlights
              .map((f) => f.flight.totalFare)
              .reduce((a, b) => a < b ? a : b);
      final maxPrice = enrichedFlights.isEmpty
          ? 1000.0
          : enrichedFlights
              .map((f) => f.flight.totalFare)
              .reduce((a, b) => a > b ? a : b);

      // Apply filters (using base flights for filtering)
      final filteredBasic = await filterFlightsUseCase(_currentFilterParams);

      // Match enriched flights to filtered flights
      final filteredEnriched = enrichedFlights
          .where((enriched) =>
              filteredBasic.any((f) => f.id == enriched.flight.id))
          .toList();

      emit(FlightLoaded(
        allFlights: enrichedFlights,
        filteredFlights: filteredEnriched,
        filterParams: _currentFilterParams,
        actualMinPrice: minPrice,
        actualMaxPrice: maxPrice,
      ));
    } catch (e) {
      emit(FlightError(e.toString()));
    }
  }

  /// Refresh flights (clear cache)
  Future<void> _onRefreshFlights(
    RefreshFlightsEvent event,
    Emitter<FlightState> emit,
  ) async {
    clearFlightCacheUseCase();

    // Reset filters
    _currentFilterParams = FilterParams(sortBy: SortType.priceLowToHigh);

    // Reload flights
    add(const LoadFlightsEvent());
  }

  /// Update price range filter
  Future<void> _onUpdatePriceRange(
    UpdatePriceRangeEvent event,
    Emitter<FlightState> emit,
  ) async {
    if (state is! FlightLoaded) return;

    final currentState = state as FlightLoaded;

    _currentFilterParams = _currentFilterParams.copyWith(
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
    );

    await _applyFilters(emit, currentState);
  }

  /// Toggle airline filter
  Future<void> _onToggleAirline(
    ToggleAirlineEvent event,
    Emitter<FlightState> emit,
  ) async {
    if (state is! FlightLoaded) return;

    final currentState = state as FlightLoaded;
    final currentAirlines = _currentFilterParams.airlineCodes?.toList() ?? [];

    if (currentAirlines.contains(event.airlineName)) {
      currentAirlines.remove(event.airlineName);
    } else {
      currentAirlines.add(event.airlineName);
    }

    _currentFilterParams = _currentFilterParams.copyWith(
      airlineCodes: currentAirlines.isEmpty ? null : currentAirlines,
    );

    await _applyFilters(emit, currentState);
  }

  /// Toggle cabin class filter
  Future<void> _onToggleCabinClass(
    ToggleCabinClassEvent event,
    Emitter<FlightState> emit,
  ) async {
    if (state is! FlightLoaded) return;

    final currentState = state as FlightLoaded;
    final currentClasses = _currentFilterParams.cabinClasses?.toList() ?? [];

    if (currentClasses.contains(event.cabinClass)) {
      currentClasses.remove(event.cabinClass);
    } else {
      currentClasses.add(event.cabinClass);
    }

    _currentFilterParams = _currentFilterParams.copyWith(
      cabinClasses: currentClasses.isEmpty ? null : currentClasses,
    );

    await _applyFilters(emit, currentState);
  }

  /// Toggle non-stop filter
  Future<void> _onToggleNonStop(
    ToggleNonStopEvent event,
    Emitter<FlightState> emit,
  ) async {
    if (state is! FlightLoaded) return;

    final currentState = state as FlightLoaded;

    _currentFilterParams = _currentFilterParams.copyWith(
      nonStopOnly: event.nonStopOnly,
    );

    await _applyFilters(emit, currentState);
  }

  /// Toggle refundable filter
  Future<void> _onToggleRefundable(
    ToggleRefundableEvent event,
    Emitter<FlightState> emit,
  ) async {
    if (state is! FlightLoaded) return;

    final currentState = state as FlightLoaded;

    _currentFilterParams = _currentFilterParams.copyWith(
      refundableOnly: event.refundableOnly,
    );

    await _applyFilters(emit, currentState);
  }

  /// Update sorting
  Future<void> _onUpdateSorting(
    UpdateSortingEvent event,
    Emitter<FlightState> emit,
  ) async {
    if (state is! FlightLoaded) return;

    final currentState = state as FlightLoaded;

    _currentFilterParams = _currentFilterParams.copyWith(
      sortBy: _stringToSortType(event.sortBy),
    );

    await _applyFilters(emit, currentState);
  }

  /// Reset all filters
  Future<void> _onResetFilters(
    ResetFiltersEvent event,
    Emitter<FlightState> emit,
  ) async {
    if (state is! FlightLoaded) return;

    final currentState = state as FlightLoaded;

    _currentFilterParams = FilterParams(
      sortBy: SortType.priceLowToHigh,
    );

    await _applyFilters(emit, currentState);
  }

  /// Get flight details
  Future<void> _onGetFlightDetails(
    GetFlightDetailsEvent event,
    Emitter<FlightState> emit,
  ) async {
    emit(const FlightDetailLoading());

    try {
      final flight = await getFlightDetailsUseCase(event.flightId);
      final enrichedFlight = await enrichFlightsUseCase(flight);
      emit(FlightDetailLoaded(enrichedFlight));
    } catch (e) {
      emit(FlightDetailError(e.toString()));
    }
  }

  /// Search flights
  Future<void> _onSearchFlights(
    SearchFlightsEvent event,
    Emitter<FlightState> emit,
  ) async {
    emit(const FlightLoading());

    try {
      final searchParams = SearchParams(
        origin: event.origin,
        destination: event.destination,
        departureDate: event.departureDate,
      );

      final flights = await searchFlightsUseCase(searchParams);
      final enrichedFlights =
          await enrichFlightsUseCase.enrichMultiple(flights);

      final minPrice = enrichedFlights.isEmpty
          ? 0.0
          : enrichedFlights
              .map((f) => f.flight.totalFare)
              .reduce((a, b) => a < b ? a : b);
      final maxPrice = enrichedFlights.isEmpty
          ? 1000.0
          : enrichedFlights
              .map((f) => f.flight.totalFare)
              .reduce((a, b) => a > b ? a : b);

      emit(FlightLoaded(
        allFlights: enrichedFlights,
        filteredFlights: enrichedFlights,
        filterParams: _currentFilterParams,
        actualMinPrice: minPrice,
        actualMaxPrice: maxPrice,
      ));
    } catch (e) {
      emit(FlightError(e.toString()));
    }
  }

  /// Apply filters helper method
  Future<void> _applyFilters(
    Emitter<FlightState> emit,
    FlightLoaded currentState,
  ) async {
    try {
      // Filter using base flights
      // final baseFlights = currentState.allFlights.map((e) => e.flight).toList();
      final filteredBasic = await filterFlightsUseCase(_currentFilterParams);

      // Match enriched flights
      final filteredEnriched = currentState.allFlights
          .where((enriched) =>
              filteredBasic.any((f) => f.id == enriched.flight.id))
          .toList();

      emit(currentState.copyWith(
        filteredFlights: filteredEnriched,
        filterParams: _currentFilterParams,
      ));
    } catch (e) {
      emit(FlightError(e.toString()));
    }
  }

  /// Helper to convert string to SortType
  SortType _stringToSortType(String sortBy) {
    switch (sortBy) {
      case 'price_low':
        return SortType.priceLowToHigh;
      case 'price_high':
        return SortType.priceHighToLow;
      case 'duration':
        return SortType.duration;
      case 'departure':
        return SortType.departureTime;
      default:
        return SortType.priceLowToHigh;
    }
  }
}
