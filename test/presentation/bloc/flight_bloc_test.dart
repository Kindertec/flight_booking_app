// test/presentation/bloc/flight_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flight_booking_app/features/flight/domain/usecases/enrich_flights.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flight_booking_app/features/flight/domain/entities/flight.dart';
import 'package:flight_booking_app/features/flight/domain/usecases/get_flights.dart';
import 'package:flight_booking_app/features/flight/domain/usecases/filter_flights.dart';
import 'package:flight_booking_app/features/flight/domain/usecases/get_flight_details.dart';
import 'package:flight_booking_app/features/flight/domain/usecases/search_flights.dart';
import 'package:flight_booking_app/features/flight/presentation/bloc/flight_bloc.dart';
import 'package:flight_booking_app/features/flight/presentation/bloc/flight_event.dart';
import 'package:flight_booking_app/features/flight/presentation/bloc/flight_state.dart';

// Mock classes
class MockGetFlights extends Mock implements GetFlights {}

class MockFilterFlights extends Mock implements FilterFlights {}

class MockGetFlightDetails extends Mock implements GetFlightDetails {}

class MockSearchFlights extends Mock implements SearchFlights {}

class MockEnrichFlights extends Mock implements EnrichFlights {}

void main() {
  late FlightBloc flightBloc;
  late MockGetFlights mockGetFlights;
  late MockFilterFlights mockFilterFlights;
  late MockGetFlightDetails mockGetFlightDetails;
  late MockSearchFlights mockSearchFlights;
  late MockEnrichFlights mockEnrichFlights;

  setUp(() {
    mockGetFlights = MockGetFlights();
    mockFilterFlights = MockFilterFlights();
    mockGetFlightDetails = MockGetFlightDetails();
    mockSearchFlights = MockSearchFlights();
    mockEnrichFlights = MockEnrichFlights();

    flightBloc = FlightBloc(
      getFlightsUseCase: mockGetFlights,
      filterFlightsUseCase: mockFilterFlights,
      getFlightDetailsUseCase: mockGetFlightDetails,
      searchFlightsUseCase: mockSearchFlights,
      enrichFlightsUseCase: mockEnrichFlights,
    );
  });

  tearDown(() {
    flightBloc.close();
  });

  // Test data
  final testFlights = [
    Flight(
      id: '1',
      airlineCode: 'HV',
      airlineName: 'Transavia Airlines',
      flightNumber: '6993',
      departureAirport: 'RTM',
      arrivalAirport: 'STN',
      departureTime: DateTime(2025, 12, 21, 12, 55),
      arrivalTime: DateTime(2025, 12, 21, 12, 50),
      duration: '55',
      cabinClass: 'BASIC',
      baseFare: 297.90,
      totalTax: 259.96,
      totalFare: 557.86,
      currency: 'USD',
      stops: 0,
      isRefundable: false,
      fareBreakdown: [],
      seatsRemaining: 4,
    ),
  ];

  group('FlightBloc', () {
    test('initial state is FlightInitial', () {
      expect(flightBloc.state, equals(const FlightInitial()));
    });

    blocTest<FlightBloc, FlightState>(
      'emits [FlightLoading, FlightLoaded] when LoadFlightsEvent is added',
      build: () {
        when(() => mockGetFlights()).thenAnswer((_) async => testFlights);
        when(() => mockFilterFlights(any()))
            .thenAnswer((_) async => testFlights);
        return flightBloc;
      },
      act: (bloc) => bloc.add(const LoadFlightsEvent()),
      expect: () => [
        const FlightLoading(),
        isA<FlightLoaded>()
            .having((s) => s.filteredFlights.length, 'flights count', 1),
      ],
      verify: (_) {
        verify(() => mockGetFlights()).called(1);
        verify(() => mockFilterFlights(any())).called(1);
      },
    );

    blocTest<FlightBloc, FlightState>(
      'emits [FlightLoading, FlightError] when LoadFlightsEvent fails',
      build: () {
        when(() => mockGetFlights()).thenThrow(Exception('Network error'));
        return flightBloc;
      },
      act: (bloc) => bloc.add(const LoadFlightsEvent()),
      expect: () => [
        const FlightLoading(),
        isA<FlightError>().having(
            (s) => s.message, 'error message', contains('Network error')),
      ],
    );

    blocTest<FlightBloc, FlightState>(
      'emits updated FlightLoaded when UpdatePriceRangeEvent is added',
      build: () {
        when(() => mockGetFlights()).thenAnswer((_) async => testFlights);
        when(() => mockFilterFlights(any()))
            .thenAnswer((_) async => testFlights);
        return flightBloc;
      },
      seed: () => FlightLoaded(
        allFlights: testFlights,
        filteredFlights: testFlights,
        filterParams: FilterParams(sortBy: SortType.priceLowToHigh),
        actualMinPrice: 0,
        actualMaxPrice: 1000,
      ),
      act: (bloc) => bloc.add(
        const UpdatePriceRangeEvent(minPrice: 100, maxPrice: 500),
      ),
      expect: () => [
        isA<FlightLoaded>().having(
          (s) => s.filterParams.minPrice,
          'min price',
          100,
        ),
      ],
      verify: (_) {
        verify(() => mockFilterFlights(any())).called(1);
      },
    );

    blocTest<FlightBloc, FlightState>(
      'emits FlightLoaded with toggled airline when ToggleAirlineEvent is added',
      build: () {
        when(() => mockFilterFlights(any()))
            .thenAnswer((_) async => testFlights);
        return flightBloc;
      },
      seed: () => FlightLoaded(
        allFlights: testFlights,
        filteredFlights: testFlights,
        filterParams: FilterParams(sortBy: SortType.priceLowToHigh),
        actualMinPrice: 0,
        actualMaxPrice: 1000,
      ),
      act: (bloc) => bloc.add(const ToggleAirlineEvent('Transavia Airlines')),
      expect: () => [
        isA<FlightLoaded>().having(
          (s) => s.filterParams.airlineCodes?.contains('Transavia Airlines'),
          'airline selected',
          true,
        ),
      ],
    );

    blocTest<FlightBloc, FlightState>(
      'emits FlightLoaded with sorted flights when UpdateSortingEvent is added',
      build: () {
        when(() => mockFilterFlights(any()))
            .thenAnswer((_) async => testFlights);
        return flightBloc;
      },
      seed: () => FlightLoaded(
        allFlights: testFlights,
        filteredFlights: testFlights,
        filterParams: FilterParams(sortBy: SortType.priceLowToHigh),
        actualMinPrice: 0,
        actualMaxPrice: 1000,
      ),
      act: (bloc) => bloc.add(const UpdateSortingEvent('price_high')),
      expect: () => [
        isA<FlightLoaded>().having(
          (s) => s.filterParams.sortBy,
          'sort type',
          SortType.priceHighToLow,
        ),
      ],
    );

    blocTest<FlightBloc, FlightState>(
      'emits FlightLoaded with reset filters when ResetFiltersEvent is added',
      build: () {
        when(() => mockFilterFlights(any()))
            .thenAnswer((_) async => testFlights);
        return flightBloc;
      },
      seed: () => FlightLoaded(
        allFlights: testFlights,
        filteredFlights: testFlights,
        filterParams: FilterParams(
          minPrice: 100,
          maxPrice: 500,
          airlineCodes: ['Transavia Airlines'],
          sortBy: SortType.priceHighToLow,
        ),
        actualMinPrice: 0,
        actualMaxPrice: 1000,
      ),
      act: (bloc) => bloc.add(const ResetFiltersEvent()),
      expect: () => [
        isA<FlightLoaded>().having(
          (s) =>
              s.filterParams.minPrice == null &&
              s.filterParams.airlineCodes == null,
          'filters reset',
          true,
        ),
      ],
    );

    blocTest<FlightBloc, FlightState>(
      'emits [FlightDetailLoading, FlightDetailLoaded] when GetFlightDetailsEvent is added',
      build: () {
        when(() => mockGetFlightDetails('1'))
            .thenAnswer((_) async => testFlights[0]);
        return flightBloc;
      },
      act: (bloc) => bloc.add(const GetFlightDetailsEvent('1')),
      expect: () => [
        const FlightDetailLoading(),
        isA<FlightDetailLoaded>().having((s) => s.flight.id, 'flight id', '1'),
      ],
      verify: (_) {
        verify(() => mockGetFlightDetails('1')).called(1);
      },
    );
  });

  group('FlightBloc Edge Cases', () {
    blocTest<FlightBloc, FlightState>(
      'handles empty flight list',
      build: () {
        when(() => mockGetFlights()).thenAnswer((_) async => []);
        when(() => mockFilterFlights(any())).thenAnswer((_) async => []);
        return flightBloc;
      },
      act: (bloc) => bloc.add(const LoadFlightsEvent()),
      expect: () => [
        const FlightLoading(),
        isA<FlightLoaded>()
            .having((s) => s.filteredFlights.isEmpty, 'empty flights', true),
      ],
    );

    blocTest<FlightBloc, FlightState>(
      'does not emit new state when filter events are added in non-loaded state',
      build: () => flightBloc,
      act: (bloc) => bloc.add(const ToggleNonStopEvent(true)),
      expect: () => [],
    );
  });
}
