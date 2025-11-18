import '../entities/flight.dart';
import '../entities/enriched_flight.dart';
import '../entities/airline.dart';
import '../entities/baggage_service.dart';
import '../repositories/reference_repository.dart';

/// Use case to enrich flights with reference data
/// Pure domain logic - no data layer dependencies
class EnrichFlights {
  final ReferenceRepository referenceRepository;

  EnrichFlights(this.referenceRepository);

  /// Enrich a single flight with reference data
  Future<EnrichedFlight> call(Flight flight) async {
    try {
      // Get airline details
      final Airline? airline = await referenceRepository.getAirlineByCode(
        flight.airlineCode,
      );

      // Get baggage services (for outbound flights)
      final List<BaggageService> baggageServices = await referenceRepository
          .getBaggageServicesByBehavior('PER_PAX_OUTBOUND');

      // Business logic: validate enrichment
      _validateEnrichment(flight, airline, baggageServices);

      return EnrichedFlight(
        flight: flight,
        airline: airline,
        availableBaggageServices: baggageServices,
      );
    } catch (e) {
      // If enrichment fails, return flight without enrichment
      // App should still work without reference data
      return EnrichedFlight(
        flight: flight,
        airline: null,
        availableBaggageServices: [],
      );
    }
  }

  /// Enrich multiple flights
  Future<List<EnrichedFlight>> enrichMultiple(List<Flight> flights) async {
    try {
      final enrichedFlights = <EnrichedFlight>[];

      for (final flight in flights) {
        final enrichedFlight = await call(flight);
        enrichedFlights.add(enrichedFlight);
      }

      return enrichedFlights;
    } catch (e) {
      throw EnrichmentException('Failed to enrich flights: ${e.toString()}');
    }
  }

  /// Validate enrichment data
  void _validateEnrichment(
    Flight flight,
    Airline? airline,
    List<BaggageService> baggageServices,
  ) {
    // Business rule: Log warning if airline not found
    if (airline == null) {
      // In production, this would log to analytics
      print(
          'Warning: Airline ${flight.airlineCode} not found in reference data');
    }

    // Business rule: Validate baggage services
    for (final service in baggageServices) {
      if (service.price < 0) {
        throw EnrichmentException('Invalid baggage service: negative price');
      }
      if (service.weightInKg <= 0) {
        throw EnrichmentException('Invalid baggage service: invalid weight');
      }
    }
  }
}

class EnrichmentException implements Exception {
  final String message;
  EnrichmentException(this.message);

  @override
  String toString() => message;
}
