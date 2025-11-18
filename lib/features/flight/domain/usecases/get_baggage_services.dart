import '../entities/baggage_service.dart';
import '../repositories/reference_repository.dart';

/// Use case for getting baggage services
class GetBaggageServices {
  final ReferenceRepository repository;

  GetBaggageServices(this.repository);

  /// Get all baggage services
  Future<List<BaggageService>> call() async {
    try {
      final services = await repository.getBaggageServices();

      // Business logic: sort by price (cheapest first)
      services.sort((a, b) => a.price.compareTo(b.price));

      return services;
    } catch (e) {
      throw BaggageServiceException(
          'Failed to get baggage services: ${e.toString()}');
    }
  }

  /// Get baggage services for outbound flights
  Future<List<BaggageService>> getOutboundServices() async {
    try {
      final services =
          await repository.getBaggageServicesByBehavior('PER_PAX_OUTBOUND');

      // Business logic: filter and validate
      final validServices = services.where((service) {
        return service.price > 0 && service.weightInKg > 0;
      }).toList();

      // Sort by weight
      validServices.sort((a, b) => a.weightInKg.compareTo(b.weightInKg));

      return validServices;
    } catch (e) {
      throw BaggageServiceException(
          'Failed to get outbound baggage services: ${e.toString()}');
    }
  }

  /// Get baggage services by weight range
  Future<List<BaggageService>> getServicesByWeightRange({
    required int minWeight,
    required int maxWeight,
  }) async {
    try {
      // Validate input
      if (minWeight < 0 || maxWeight < 0) {
        throw InvalidWeightRangeException('Weight must be positive');
      }

      if (minWeight > maxWeight) {
        throw InvalidWeightRangeException(
            'Min weight cannot be greater than max weight');
      }

      final allServices = await call();

      return allServices.where((service) {
        return service.weightInKg >= minWeight &&
            service.weightInKg <= maxWeight;
      }).toList();
    } catch (e) {
      if (e is InvalidWeightRangeException) rethrow;
      throw BaggageServiceException(
          'Failed to filter baggage services: ${e.toString()}');
    }
  }
}

class BaggageServiceException implements Exception {
  final String message;
  BaggageServiceException(this.message);

  @override
  String toString() => message;
}

class InvalidWeightRangeException implements Exception {
  final String message;
  InvalidWeightRangeException(this.message);

  @override
  String toString() => message;
}
