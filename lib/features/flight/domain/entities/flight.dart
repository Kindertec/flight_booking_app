class Flight {
  final String id;
  final String airlineCode;
  final String airlineName;
  final String flightNumber;
  final String departureAirport;
  final String arrivalAirport;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String duration;
  final String cabinClass;
  final double baseFare;
  final double totalTax;
  final double totalFare;
  final String currency;
  final int stops;
  final bool isRefundable;
  final List<FareBreakdown> fareBreakdown;
  final int seatsRemaining;

  Flight({
    required this.id,
    required this.airlineCode,
    required this.airlineName,
    required this.flightNumber,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.cabinClass,
    required this.baseFare,
    required this.totalTax,
    required this.totalFare,
    required this.currency,
    required this.stops,
    required this.isRefundable,
    required this.fareBreakdown,
    required this.seatsRemaining,
  });
}

class FareBreakdown {
  final String passengerType;
  final int quantity;
  final double baseFare;
  final double taxes;
  final double totalFare;
  final List<String> baggage;
  final List<String> cabinBaggage;
  final bool refundAllowed;
  final bool changeAllowed;

  FareBreakdown({
    required this.passengerType,
    required this.quantity,
    required this.baseFare,
    required this.taxes,
    required this.totalFare,
    required this.baggage,
    required this.cabinBaggage,
    required this.refundAllowed,
    required this.changeAllowed,
  });
}
