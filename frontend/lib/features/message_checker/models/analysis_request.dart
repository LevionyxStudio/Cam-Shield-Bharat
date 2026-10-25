/// Represents an input request submitted for scam and fraud analysis.
class AnalysisRequest {
  /// The body of the message (SMS, WhatsApp, email, or chat) to analyze.
  final String messageText;

  /// Optional ISO language code hint (e.g. 'en', 'hi', 'pa').
  final String? languageCode;

  /// Optional sender identifier (e.g. phone number, SMS sender ID like 'SBI-INB', or 'Unknown').
  final String? sender;

  /// Timestamp when the request was initiated.
  final DateTime createdAt;

  AnalysisRequest({
    required String messageText,
    this.languageCode,
    this.sender,
    DateTime? createdAt,
  })  : messageText = _validateMessage(messageText),
        createdAt = createdAt ?? DateTime.now();

  static String _validateMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        text,
        'messageText',
        'Message text cannot be empty or purely whitespace.',
      );
    }
    return trimmed;
  }

  /// Serializes the request to a JSON map.
  Map<String, dynamic> toJson() => {
    'message_text': messageText,
    if (languageCode != null) 'language_code': languageCode,
    if (sender != null) 'sender': sender,
    'created_at': createdAt.toIso8601String(),
  };

  /// Deserializes an [AnalysisRequest] from a JSON map.
  factory AnalysisRequest.fromJson(Map<String, dynamic> json) {
    final rawText = json['message_text'];
    if (rawText is! String) {
      throw const FormatException('AnalysisRequest requires a string "message_text".');
    }

    DateTime? timestamp;
    final rawTime = json['created_at'];
    if (rawTime != null) {
      if (rawTime is! String) {
        throw const FormatException('AnalysisRequest "created_at" must be an ISO-8601 string.');
      }
      timestamp = DateTime.tryParse(rawTime);
      if (timestamp == null) {
        throw FormatException('Invalid ISO-8601 date format: "$rawTime".');
      }
    }

    final rawLang = json['language_code'];
    if (rawLang != null && rawLang is! String) {
      throw const FormatException('AnalysisRequest "language_code" must be a string if present.');
    }

    final rawSender = json['sender'];
    if (rawSender != null && rawSender is! String) {
      throw const FormatException('AnalysisRequest "sender" must be a string if present.');
    }

    return AnalysisRequest(
      messageText: rawText,
      languageCode: rawLang as String?,
      sender: rawSender as String?,
      createdAt: timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisRequest &&
          runtimeType == other.runtimeType &&
          messageText == other.messageText &&
          languageCode == other.languageCode &&
          sender == other.sender;

  @override
  int get hashCode => Object.hash(messageText, languageCode, sender);

  @override
  String toString() =>
      'AnalysisRequest(textLength: ${messageText.length}, lang: $languageCode, sender: $sender)';
}
