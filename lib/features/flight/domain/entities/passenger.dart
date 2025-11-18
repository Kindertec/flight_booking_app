class Passenger {
  final String type; // Adult, Child, Infant
  final String firstName;
  final String lastName;
  final String title;
  final String eTicketNumber;
  final DateTime dateOfBirth;
  final String email;
  final String? gender;
  final String nationality;
  final String passportNumber;
  final String phoneNumber;

  const Passenger({
    required this.type,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.eTicketNumber,
    required this.dateOfBirth,
    required this.email,
    this.gender,
    required this.nationality,
    required this.passportNumber,
    required this.phoneNumber,
  });

  String get fullName => '$title $firstName $lastName';

  int get age {
    final now = DateTime.now();
    int calculatedAge = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Passenger && other.eTicketNumber == eTicketNumber;
  }

  @override
  int get hashCode => eTicketNumber.hashCode;
}
