import '../../domain/entities/booking.dart';
import '../../domain/entities/passenger.dart';

class PassengerModel extends Passenger {
  const PassengerModel({
    required super.type,
    required super.firstName,
    required super.lastName,
    required super.title,
    required super.eTicketNumber,
    required super.dateOfBirth,
    required super.email,
    super.gender,
    required super.nationality,
    required super.passportNumber,
    required super.phoneNumber,
  });

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    // Convert passenger type code to readable name
    String getPassengerType(String code) {
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

    return PassengerModel(
      type: getPassengerType(json['PassengerType'] as String),
      firstName: json['PassengerFirstName'] as String,
      lastName: json['PassengerLastName'] as String,
      title: json['PassengerTitle'] as String,
      eTicketNumber: json['eTicketNumber'] as String,
      dateOfBirth: DateTime.parse(json['DateOfBirth'] as String),
      email: json['EmailAddress'] as String,
      gender: json['Gender'] as String?,
      nationality: json['PassengerNationality'] as String,
      passportNumber: json['PassportNumber'] as String,
      phoneNumber: json['PhoneNumber'] as String,
    );
  }

  /// Convert to domain entity
  Passenger toEntity() {
    return Passenger(
      type: type,
      firstName: firstName,
      lastName: lastName,
      title: title,
      eTicketNumber: eTicketNumber,
      dateOfBirth: dateOfBirth,
      email: email,
      gender: gender,
      nationality: nationality,
      passportNumber: passportNumber,
      phoneNumber: phoneNumber,
    );
  }
}

/// Data model for booking
class BookingModel extends Booking {
  const BookingModel({
    required super.bookingStatus,
    required super.destination,
    required super.fareType,
    required super.isCommissionable,
    required super.passengers,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final itineraryInfo = json['ItineraryInfo'];
    final customerInfos = itineraryInfo['CustomerInfos'] as List;

    return BookingModel(
      bookingStatus: json['BookingStatus'] as String,
      destination: json['Destination'] as String,
      fareType: json['FareType'] as String,
      isCommissionable: json['IsCommissionable'] as bool,
      passengers: customerInfos
          .map((info) => PassengerModel.fromJson(info['CustomerInfo']))
          .toList(),
    );
  }

  /// Convert to domain entity
  Booking toEntity() {
    return Booking(
      bookingStatus: bookingStatus,
      destination: destination,
      fareType: fareType,
      isCommissionable: isCommissionable,
      passengers: passengers,
    );
  }
}

/// Response wrapper for trip details
class TripDetailsResponse {
  final bool success;
  final String target;
  final BookingModel booking;
  final String uniqueId;
  final String origin;
  final String ticketStatus;
  final ItineraryPricing? pricing;
  final List<ReservationItem> reservationItems;
  final List<ExtraService> extraServices;

  TripDetailsResponse({
    required this.success,
    required this.target,
    required this.booking,
    required this.uniqueId,
    required this.origin,
    required this.ticketStatus,
    this.pricing,
    required this.reservationItems,
    required this.extraServices,
  });

  factory TripDetailsResponse.fromJson(Map<String, dynamic> json) {
    final response = json['TripDetailsResponse']['TripDetailsResult'];
    final itinerary = response['TravelItinerary'];
    final itineraryInfo = itinerary['ItineraryInfo'];

    return TripDetailsResponse(
      success: response['Success'] == 'true',
      target: response['Target'] as String,
      booking: BookingModel.fromJson(itinerary),
      uniqueId: itinerary['UniqueID'] as String,
      origin: itinerary['Origin'] as String,
      ticketStatus: itinerary['TicketStatus'] as String,
      pricing: itineraryInfo['ItineraryPricing'] != null
          ? ItineraryPricing.fromJson(itineraryInfo['ItineraryPricing'])
          : null,
      reservationItems: (itineraryInfo['ReservationItems'] as List)
          .map((item) => ReservationItem.fromJson(item['ReservationItem']))
          .toList(),
      extraServices: itineraryInfo['ExtraServices'] != null &&
              itineraryInfo['ExtraServices']['Services'] != null
          ? (itineraryInfo['ExtraServices']['Services'] as List)
              .map((service) => ExtraService.fromJson(service['Service']))
              .toList()
          : [],
    );
  }
}

/// Itinerary pricing details (trip-details.json(ItineraryPricing))
class ItineraryPricing {
  final double equiFare;
  final double serviceTax;
  final double tax;
  final double totalFare;
  final String currency;

  ItineraryPricing({
    required this.equiFare,
    required this.serviceTax,
    required this.tax,
    required this.totalFare,
    required this.currency,
  });

  factory ItineraryPricing.fromJson(Map<String, dynamic> json) {
    return ItineraryPricing(
      equiFare: double.parse(json['EquiFare']['Amount'] as String),
      serviceTax: double.parse(json['ServiceTax']['Amount'] as String),
      tax: double.parse(json['Tax']['Amount'] as String),
      totalFare: double.parse(json['TotalFare']['Amount'] as String),
      currency: json['TotalFare']['CurrencyCode'] as String,
    );
  }
}

/// Reservation item (flight segment in booking)
class ReservationItem {
  final String airlinePNR;
  final String departureAirport;
  final String arrivalAirport;
  final DateTime departureDateTime;
  final DateTime arrivalDateTime;
  final String flightNumber;
  final String marketingAirlineCode;
  final String operatingAirlineCode;
  final String cabinClass;
  final String baggage;
  final int journeyDuration;
  final int stopQuantity;

  ReservationItem({
    required this.airlinePNR,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureDateTime,
    required this.arrivalDateTime,
    required this.flightNumber,
    required this.marketingAirlineCode,
    required this.operatingAirlineCode,
    required this.cabinClass,
    required this.baggage,
    required this.journeyDuration,
    required this.stopQuantity,
  });

  factory ReservationItem.fromJson(Map<String, dynamic> json) {
    return ReservationItem(
      airlinePNR: json['AirlinePNR'] as String,
      departureAirport: json['DepartureAirportLocationCode'] as String,
      arrivalAirport: json['ArrivalAirportLocationCode'] as String,
      departureDateTime: DateTime.parse(json['DepartureDateTime'] as String),
      arrivalDateTime: DateTime.parse(json['ArrivalDateTime'] as String),
      flightNumber: json['FlightNumber'] as String,
      marketingAirlineCode: json['MarketingAirlineCode'] as String,
      operatingAirlineCode: json['OperatingAirlineCode'] as String,
      cabinClass: json['CabinClassText'] as String,
      baggage: json['Baggage'] as String,
      journeyDuration: int.parse(json['JourneyDuration'] as String),
      stopQuantity: json['StopQuantity'] as int,
    );
  }
}

/// Extra service (baggage, meals, seats that were added to booking)
class ExtraService {
  final String serviceId;
  final String type;
  final String description;
  final String behavior;
  final String checkInType;
  final bool isMandatory;
  final double price;
  final String currency;

  ExtraService({
    required this.serviceId,
    required this.type,
    required this.description,
    required this.behavior,
    required this.checkInType,
    required this.isMandatory,
    required this.price,
    required this.currency,
  });

  factory ExtraService.fromJson(Map<String, dynamic> json) {
    return ExtraService(
      serviceId: json['ServiceId'] as String,
      type: json['Type'] as String,
      description: json['Description'] as String,
      behavior: json['Behavior'] as String,
      checkInType: json['CheckInType'] as String,
      isMandatory: json['IsMandatory'] as bool,
      price: double.parse(json['ServiceCost']['Amount'] as String),
      currency: json['ServiceCost']['CurrencyCode'] as String,
    );
  }
}
