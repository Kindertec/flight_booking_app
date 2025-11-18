class Airline {
  final String code;
  final String name;
  final String logoUrl;

  const Airline({
    required this.code,
    required this.name,
    required this.logoUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Airline &&
        other.code == code &&
        other.name == name &&
        other.logoUrl == logoUrl;
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode ^ logoUrl.hashCode;
}
