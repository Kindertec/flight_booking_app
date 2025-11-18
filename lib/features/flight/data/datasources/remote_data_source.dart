import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/flight.dart';
import '../models/flight_model.dart';

class RemoteDataSource {
  final http.Client client;
  final String baseUrl;

  RemoteDataSource({
    required this.client,
    this.baseUrl = 'https://api.example.com', // Replace with actual API
  });

  /// Fetch flights from the API endpoint
  Future<List<Flight>> getFlights() async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/flights/search'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': 'dev_api',
          'user_password': '**********',
          'access': 'Test',
          'ip_address': '**.**.**.225',
          'requiredCurrency': 'USD',
          'journeyType': 'OneWay',
          'OriginDestinationInfo': [
            {
              'departureDate': '2025-12-21',
              'airportOriginCode': 'AMS',
              'airportDestinationCode': 'LON'
            }
          ],
          'class': 'Economy',
          'adults': 2,
          'childs': 1,
          'infants': 1,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> fareItineraries =
            jsonData['AirSearchResponse']['AirSearchResult']['FareItineraries'];

        return fareItineraries
            .map((itinerary) => FlightModel.fromJson(itinerary))
            .toList();
      } else {
        throw RemoteDataSourceException(
          'Failed to fetch flights. Status code: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw RemoteDataSourceException('Network error: ${e.message}');
    } catch (e) {
      throw RemoteDataSourceException('Unexpected error: ${e.toString()}');
    }
  }

  /// Search flights with specific parameters
  Future<List<Flight>> searchFlights({
    required String origin,
    required String destination,
    required String departureDate,
    required int adults,
    int children = 0,
    int infants = 0,
    String cabinClass = 'Economy',
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/flights/search'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': 'dev_api',
          'user_password': '**********',
          'access': 'Test',
          'requiredCurrency': 'USD',
          'journeyType': 'OneWay',
          'OriginDestinationInfo': [
            {
              'departureDate': departureDate,
              'airportOriginCode': origin,
              'airportDestinationCode': destination,
            }
          ],
          'class': cabinClass,
          'adults': adults,
          'childs': children,
          'infants': infants,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> fareItineraries =
            jsonData['AirSearchResponse']['AirSearchResult']['FareItineraries'];

        return fareItineraries
            .map((itinerary) => FlightModel.fromJson(itinerary))
            .toList();
      } else {
        throw RemoteDataSourceException(
          'Failed to search flights. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw RemoteDataSourceException(
          'Failed to search flights: ${e.toString()}');
    }
  }

  /// Get flight details by ID
  Future<Flight?> getFlightById(String id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/flights/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return FlightModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw RemoteDataSourceException(
          'Failed to get flight. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw RemoteDataSourceException('Failed to get flight: ${e.toString()}');
    }
  }
}

/// Custom exception for remote data source errors
class RemoteDataSourceException implements Exception {
  final String message;
  RemoteDataSourceException(this.message);

  @override
  String toString() => message;
}
