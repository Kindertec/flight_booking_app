import '../entities/airline.dart';
import '../entities/baggage_service.dart';
import '../entities/booking.dart';

/// Abstract repository interface - domain layer doesn't know about implementation
abstract class ReferenceRepository {
  /// Get airline by code
  Future<Airline?> getAirlineByCode(String code);

  /// Get all airlines
  Future<List<Airline>> getAllAirlines();

  /// Search airlines by name or code
  Future<List<Airline>> searchAirlines(String query);

  /// Get baggage services
  Future<List<BaggageService>> getBaggageServices();

  /// Get baggage services filtered by behavior
  Future<List<BaggageService>> getBaggageServicesByBehavior(String behavior);

  /// Get example booking (for template/demo purposes)
  Future<Booking?> getExampleBooking();
}
