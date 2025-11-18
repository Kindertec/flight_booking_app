import '../../domain/entities/airline.dart';
import '../../domain/entities/baggage_service.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/reference_repository.dart';
import '../datasources/reference_data_source.dart';

class ReferenceRepositoryImpl implements ReferenceRepository {
  final ReferenceDataSource dataSource;

  ReferenceRepositoryImpl(this.dataSource);

  @override
  Future<Airline?> getAirlineByCode(String code) async {
    try {
      final airlineModel = dataSource.getAirlineByCode(code);
      // Convert model to entity (pure domain object)
      return airlineModel?.toEntity();
    } catch (e) {
      throw RepositoryException('Failed to get airline: ${e.toString()}');
    }
  }

  @override
  Future<List<Airline>> getAllAirlines() async {
    try {
      final airlineModels = dataSource.getAllAirlines();
      // Convert all models to entities
      return airlineModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw RepositoryException('Failed to get airlines: ${e.toString()}');
    }
  }

  @override
  Future<List<Airline>> searchAirlines(String query) async {
    try {
      final airlineModels = dataSource.searchAirlines(query);
      return airlineModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw RepositoryException('Failed to search airlines: ${e.toString()}');
    }
  }

  @override
  Future<List<BaggageService>> getBaggageServices() async {
    try {
      final serviceModels = dataSource.getAllBaggageServices();
      // Convert all models to entities
      return serviceModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw RepositoryException(
          'Failed to get baggage services: ${e.toString()}');
    }
  }

  @override
  Future<List<BaggageService>> getBaggageServicesByBehavior(
    String behavior,
  ) async {
    try {
      final serviceModels = dataSource.getBaggageServicesByBehavior(behavior);
      return serviceModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw RepositoryException(
        'Failed to get baggage services by behavior: ${e.toString()}',
      );
    }
  }

  @override
  Future<Booking?> getExampleBooking() async {
    try {
      final bookingModel = dataSource.getExampleBooking();
      // Convert model to entity
      return bookingModel?.toEntity();
    } catch (e) {
      throw RepositoryException('Failed to get booking: ${e.toString()}');
    }
  }
}

class RepositoryException implements Exception {
  final String message;
  RepositoryException(this.message);

  @override
  String toString() => message;
}
