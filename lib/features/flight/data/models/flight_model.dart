import '../../domain/entities/flight.dart';

class FlightModel extends Flight {
  FlightModel({
    required super.id,
    required super.airlineCode,
    required super.airlineName,
    required super.flightNumber,
    required super.departureAirport,
    required super.arrivalAirport,
    required super.departureTime,
    required super.arrivalTime,
    required super.duration,
    required super.cabinClass,
    required super.baseFare,
    required super.totalTax,
    required super.totalFare,
    required super.currency,
    required super.stops,
    required super.isRefundable,
    required super.fareBreakdown,
    required super.seatsRemaining,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    try {
      final fareItinerary = json['FareItinerary'];
      final fareInfo = fareItinerary['AirItineraryFareInfo'];
      final segment = fareItinerary['OriginDestinationOptions'][0]
          ['OriginDestinationOption'][0]['FlightSegment'];
      final seatsInfo = fareItinerary['OriginDestinationOptions'][0]
          ['OriginDestinationOption'][0]['SeatsRemaining'];

      return FlightModel(
        id: fareInfo['FareSourceCode'],
        airlineCode: segment['MarketingAirlineCode'],
        airlineName: segment['MarketingAirlineName'],
        flightNumber: segment['FlightNumber'],
        departureAirport: segment['DepartureAirportLocationCode'],
        arrivalAirport: segment['ArrivalAirportLocationCode'],
        departureTime: DateTime.parse(segment['DepartureDateTime']),
        arrivalTime: DateTime.parse(segment['ArrivalDateTime']),
        duration: segment['JourneyDuration'],
        cabinClass: segment['CabinClassText'],
        baseFare: double.parse(
          fareInfo['ItinTotalFares']['BaseFare']['Amount'],
        ),
        totalTax: double.parse(
          fareInfo['ItinTotalFares']['TotalTax']['Amount'],
        ),
        totalFare: double.parse(
          fareInfo['ItinTotalFares']['TotalFare']['Amount'],
        ),
        currency: fareInfo['ItinTotalFares']['TotalFare']['CurrencyCode'],
        stops: fareItinerary['OriginDestinationOptions'][0]['TotalStops'],
        isRefundable: fareInfo['IsRefundable'] == 'Yes',
        fareBreakdown: (fareInfo['FareBreakdown'] as List)
            .map((e) => FareBreakdownModel.fromJson(e))
            .toList(),
        seatsRemaining: seatsInfo['Number'],
      );
    } catch (e) {
      throw Exception('Error parsing flight: $e');
    }
  }
}

class FareBreakdownModel extends FareBreakdown {
  FareBreakdownModel({
    required super.passengerType,
    required super.quantity,
    required super.baseFare,
    required super.taxes,
    required super.totalFare,
    required super.baggage,
    required super.cabinBaggage,
    required super.refundAllowed,
    required super.changeAllowed,
  });

  factory FareBreakdownModel.fromJson(Map<String, dynamic> json) {
    final passengerFare = json['PassengerFare'];
    final passengerType = json['PassengerTypeQuantity'];
    final penalty = json['PenaltyDetails'];

    double totalTaxes = 0;
    if (passengerFare['Taxes'] != null) {
      for (var tax in passengerFare['Taxes']) {
        totalTaxes += double.parse(tax['Amount']);
      }
    }

    return FareBreakdownModel(
      passengerType: _getPassengerTypeName(passengerType['Code']),
      quantity: passengerType['Quantity'],
      baseFare: double.parse(passengerFare['BaseFare']['Amount']),
      taxes: totalTaxes,
      totalFare: double.parse(passengerFare['TotalFare']['Amount']),
      baggage: List<String>.from(json['Baggage']),
      cabinBaggage: List<String>.from(json['CabinBaggage']),
      refundAllowed: penalty['RefundAllowed'],
      changeAllowed: penalty['ChangeAllowed'],
    );
  }

  static String _getPassengerTypeName(String code) {
    switch (code) {
      case 'ADT':
        return 'Adult';
      case 'CHD':
        return 'Child';
      case 'INF':
        return 'Infant';
      default:
        return code;
    }
  }
}
