/// Represents the assessed severity level of a message.
enum RiskLevel {
  /// The message exhibits no identifiable scam patterns or deceptive intent.
  safe('safe'),

  /// The message exhibits questionable characteristics or unverified links,
  /// but lacks definitive threat signals. User caution is advised.
  suspicious('suspicious'),

  /// The message exhibits definitive fraud indicators (e.g. digital arrest threats,
  /// fake KYC cancellation, credential harvesting, or payment coercion).
  dangerous('dangerous');

  const RiskLevel(this.value);

  /// String identifier used in serialization and reporting.
  final String value;

  /// Parses a [RiskLevel] from a raw string value.
  ///
  /// Throws a [FormatException] if [raw] does not match a known risk level.
  static RiskLevel fromString(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'safe':
        return RiskLevel.safe;
      case 'suspicious':
        return RiskLevel.suspicious;
      case 'dangerous':
        return RiskLevel.dangerous;
      default:
        throw FormatException(
          'Unknown risk level: "$raw". Expected safe, suspicious, or dangerous.',
        );
    }
  }

  /// Serializes the risk level to its JSON string representation.
  String toJson() => value;
}
