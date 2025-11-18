import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/airline_model.dart';
import '../models/baggage_service_model.dart';
import '../models/booking_model.dart';

class ReferenceDataSource {
  // Cache for loaded data
  List<AirlineModel>? _airlines;
  ExtraServicesResponse? _extraServices;
  TripDetailsResponse? _tripDetails;

  /// Load all reference data
  Future<void> loadAllReferenceData() async {
    await Future.wait([
      loadAirlines(),
      loadExtraServices(),
      loadTripDetails(),
    ]);
  }

  /// Load airline list from JSON
  Future<void> loadAirlines() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/json/airline-list.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _airlines = jsonList.map((json) => AirlineModel.fromJson(json)).toList();

      print('✅ Loaded ${_airlines!.length} airlines');
    } catch (e) {
      print('❌ Error loading airlines: $e');
      _airlines = [];
      rethrow;
    }
  }

  /// Load extra services (baggage options)
  Future<void> loadExtraServices() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/json/extra-services.json');
      final jsonData = json.decode(jsonString);

      _extraServices = ExtraServicesResponse.fromJson(jsonData);

      print('✅ Loaded extra services');
    } catch (e) {
      print('❌ Error loading extra services: $e');
      rethrow;
    }
  }

  /// Load trip details (example booking data)
  Future<void> loadTripDetails() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/json/trip-details.json');
      final jsonData = json.decode(jsonString);

      _tripDetails = TripDetailsResponse.fromJson(jsonData);

      print('✅ Loaded trip details');
    } catch (e) {
      print('❌ Error loading trip details: $e');
      rethrow;
    }
  }

  /// Get airline by code
  AirlineModel? getAirlineByCode(String code) {
    if (_airlines == null) return null;

    try {
      return _airlines!.firstWhere(
        (airline) => airline.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all airlines
  List<AirlineModel> getAllAirlines() {
    return _airlines ?? [];
  }

  /// Search airlines
  List<AirlineModel> searchAirlines(String query) {
    if (_airlines == null || query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return _airlines!
        .where((airline) =>
            airline.name.toLowerCase().contains(lowerQuery) ||
            airline.code.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get all baggage services
  List<BaggageServiceModel> getAllBaggageServices() {
    return _extraServices?.getAllServices() ?? [];
  }

  /// Get baggage services by behaviour
  List<BaggageServiceModel> getBaggageServicesByBehavior(String behavior) {
    return _extraServices?.getServicesByBehavior(behavior) ?? [];
  }

  /// Get example booking
  BookingModel? getExampleBooking() {
    return _tripDetails?.booking;
  }

  /// Check if data is loaded
  bool get isAirlinesLoaded => _airlines != null && _airlines!.isNotEmpty;
  bool get isExtraServicesLoaded => _extraServices != null;
  bool get isTripDetailsLoaded => _tripDetails != null;
  bool get isAllDataLoaded =>
      isAirlinesLoaded && isExtraServicesLoaded && isTripDetailsLoaded;
}
