import '../../domain/entities/airline.dart';

class AirlineModel extends Airline {
  const AirlineModel({
    required super.code,
    required super.name,
    required super.logoUrl,
  });

  factory AirlineModel.fromJson(Map<String, dynamic> json) {
    return AirlineModel(
      code: json['AirLineCode'] as String,
      name: json['AirLineName'] as String,
      logoUrl: json['AirLineLogo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AirLineCode': code,
      'AirLineName': name,
      'AirLineLogo': logoUrl,
    };
  }

  /// Convert to domain entity
  Airline toEntity() {
    return Airline(
      code: code,
      name: name,
      logoUrl: logoUrl,
    );
  }

  /// Create from domain entity
  factory AirlineModel.fromEntity(Airline airline) {
    return AirlineModel(
      code: airline.code,
      name: airline.name,
      logoUrl: airline.logoUrl,
    );
  }
}
