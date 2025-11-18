import 'package:flight_booking_app/features/flight/domain/usecases/clear_flight_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// Domain - Flight
import 'package:flight_booking_app/features/flight/domain/repositories/flight_repository.dart';
import 'package:flight_booking_app/features/flight/domain/usecases/get_flights.dart';
import 'package:flight_booking_app/features/flight/domain/usecases/filter_flights.dart';
import 'package:flight_booking_app/features/flight/domain/usecases/get_flight_details.dart';
import 'package:flight_booking_app/features/flight/domain/usecases/search_flights.dart';

// Domain - Reference Data
import 'package:flight_booking_app/features/flight/domain/repositories/reference_repository.dart';
import 'package:flight_booking_app/features/flight/domain/usecases/enrich_flights.dart';

// Data - Flight
import 'package:flight_booking_app/features/flight/data/repositories/flight_repository_impl.dart';
import 'package:flight_booking_app/features/flight/data/datasources/local_data_source.dart';
import 'package:flight_booking_app/features/flight/data/datasources/remote_data_source.dart';

// Data - Reference Data
import 'package:flight_booking_app/features/flight/data/repositories/reference_repository_impl.dart';
import 'package:flight_booking_app/features/flight/data/datasources/reference_data_source.dart';

// Presentation
import 'package:flight_booking_app/features/flight/presentation/bloc/flight_bloc.dart';
import 'package:flight_booking_app/features/flight/presentation/bloc/flight_event.dart';
import 'package:flight_booking_app/features/flight/presentation/screens/flights_list_screen.dart';
import 'core/theme.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize and load reference data
  final referenceDataSource = ReferenceDataSource();
  await referenceDataSource.loadAllReferenceData();

  runApp(MyApp(referenceDataSource: referenceDataSource));
}

class MyApp extends StatelessWidget {
  final ReferenceDataSource referenceDataSource;

  const MyApp({
    Key? key,
    required this.referenceDataSource,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ============================================
    // DEPENDENCY INJECTION - Clean Architecture
    // ============================================

    // 1. DATA SOURCES
    final localDataSource = LocalDataSource();
    final remoteDataSource = RemoteDataSource(
      client: http.Client(),
      baseUrl: 'https://api.example.com',
    );

    // 2. REPOSITORIES (Data Layer → Domain Layer)
    final FlightRepository flightRepository = FlightRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );

    final ReferenceRepository referenceRepository = ReferenceRepositoryImpl(
      referenceDataSource,
    );

    // 3. USE CASES (Domain Layer)
    // Flight Use Cases
    final getFlightsUseCase = GetFlights(flightRepository);
    final filterFlightsUseCase = FilterFlights(flightRepository);
    final getFlightDetailsUseCase = GetFlightDetails(flightRepository);
    final searchFlightsUseCase = SearchFlights(flightRepository);
    final clearFlightCacheUseCase = ClearFlightCache(flightRepository);

    // Reference Data Use Cases
    // final getAirlineUseCase = GetAirline(referenceRepository);
    // final getBaggageServicesUseCase = GetBaggageServices(referenceRepository);
    final enrichFlightsUseCase = EnrichFlights(referenceRepository);

    // 4. BLoC (Presentation Layer)
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FlightBloc(
            getFlightsUseCase: getFlightsUseCase,
            filterFlightsUseCase: filterFlightsUseCase,
            getFlightDetailsUseCase: getFlightDetailsUseCase,
            searchFlightsUseCase: searchFlightsUseCase,
            enrichFlightsUseCase: enrichFlightsUseCase,
            clearFlightCacheUseCase: clearFlightCacheUseCase,
          )..add(const LoadFlightsEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Flight Booking',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const FlightsListScreen(),
      ),
    );
  }
}
