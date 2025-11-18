import '../repositories/flight_repository.dart';

/// Use case for clearing cache
/// Encapsulates business logic and keeps it separate from UI
class ClearFlightCache {
  final FlightRepository repository;

  ClearFlightCache(this.repository);

  void call() {
    repository.clearCache();
  }
}
