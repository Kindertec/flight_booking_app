import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/flight.dart';
import '../models/flight_model.dart';

class LocalDataSource {
  Future<List<Flight>> getFlights() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(
        'assets/json/flights.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> fareItineraries =
          jsonData['AirSearchResponse']['AirSearchResult']['FareItineraries'];

      return fareItineraries
          .map((itinerary) => FlightModel.fromJson(itinerary))
          .toList();
    } catch (e) {
      throw Exception('Failed to load flights: $e');
    }
  }
}
