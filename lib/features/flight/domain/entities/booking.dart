import 'passenger.dart';

class Booking {
  final String bookingStatus;
  final String destination;
  final String fareType;
  final bool isCommissionable;
  final List<Passenger> passengers;

  const Booking({
    required this.bookingStatus,
    required this.destination,
    required this.fareType,
    required this.isCommissionable,
    required this.passengers,
  });

  List<Passenger> get adults {
    return passengers.where((p) => p.type == 'Adult').toList();
  }

  List<Passenger> get children {
    return passengers.where((p) => p.type == 'Child').toList();
  }

  List<Passenger> get infants {
    return passengers.where((p) => p.type == 'Infant').toList();
  }

  int get totalPassengers => passengers.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking &&
        other.bookingStatus == bookingStatus &&
        other.destination == destination;
  }

  @override
  int get hashCode => bookingStatus.hashCode ^ destination.hashCode;
}
