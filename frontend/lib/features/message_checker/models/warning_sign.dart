/// Represents a specific deceptive tactic, red flag, or risk factor
/// detected within an analyzed message.
class WarningSign {
  /// Machine-readable identifier for the red flag (e.g. 'urgent_action', 'police_impersonation').
  final String code;

  /// Human-readable title describing the warning sign.
  final String title;

  /// Optional contextual explanation or detail about where and why this flag was raised.
  final String? description;

  const WarningSign({
    required this.code,
    required this.title,
    this.description,
  });

  /// Convenience factory to create a [WarningSign] from a descriptive title.
  factory WarningSign.fromTitle(String title, [String? description]) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Warning sign title cannot be empty.');
    }
    final generatedCode = trimmed
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return WarningSign(
      code: generatedCode.isEmpty ? 'warning' : generatedCode,
      title: trimmed,
      description: description?.trim(),
    );
  }

  /// Serializes the warning sign to a JSON map.
  Map<String, dynamic> toJson() => {
    'code': code,
    'title': title,
    if (description != null) 'description': description,
  };

  /// Deserializes a [WarningSign] from a JSON map.
  factory WarningSign.fromJson(Map<String, dynamic> json) {
    final rawCode = json['code'];
    final rawTitle = json['title'];

    if (rawCode is! String || rawCode.trim().isEmpty) {
      throw const FormatException('WarningSign requires a non-empty string "code".');
    }
    if (rawTitle is! String || rawTitle.trim().isEmpty) {
      throw const FormatException('WarningSign requires a non-empty string "title".');
    }

    final rawDesc = json['description'];
    if (rawDesc != null && rawDesc is! String) {
      throw const FormatException('WarningSign "description" must be a string if present.');
    }

    return WarningSign(
      code: rawCode.trim(),
      title: rawTitle.trim(),
      description: (rawDesc as String?)?.trim(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WarningSign &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          title == other.title &&
          description == other.description;

  @override
  int get hashCode => Object.hash(code, title, description);

  @override
  String toString() => 'WarningSign(code: $code, title: $title)';
}
