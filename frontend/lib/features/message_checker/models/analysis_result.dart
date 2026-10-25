import 'analysis_source.dart';
import 'risk_level.dart';
import 'warning_sign.dart';

/// Represents the evaluated verdict and details for an analyzed message.
class AnalysisResult {
  /// Overall assessed risk classification: safe, suspicious, or dangerous.
  final RiskLevel riskLevel;

  /// Normalized numerical risk score from 0 (completely harmless) to 100 (definitive scam).
  final int riskScore;

  /// Clear, user-facing natural language explanation of the verdict.
  final String explanation;

  /// Typed list of specific deception signals or red flags identified.
  final List<WarningSign> warningSigns;

  /// Actionable safety recommendations for the user.
  final List<String> recommendations;

  /// The engine or evaluator that produced this result.
  final AnalysisSource source;

  /// Timestamp when the analysis was generated.
  final DateTime analyzedAt;

  AnalysisResult({
    required this.riskLevel,
    required int riskScore,
    required this.explanation,
    List<WarningSign>? warningSigns,
    List<String>? recommendations,
    required this.source,
    DateTime? analyzedAt,
  })  : riskScore = _validateScore(riskScore),
        warningSigns = List.unmodifiable(warningSigns ?? const <WarningSign>[]),
        recommendations = List.unmodifiable(recommendations ?? const <String>[]),
        analyzedAt = analyzedAt ?? DateTime.now();

  static int _validateScore(int score) {
    if (score < 0 || score > 100) {
      throw ArgumentError.value(
        score,
        'riskScore',
        'Risk score must be between 0 and 100 inclusive.',
      );
    }
    return score;
  }

  /// Serializes the result to a JSON map.
  Map<String, dynamic> toJson() => {
    'risk_level': riskLevel.toJson(),
    'risk_score': riskScore,
    'explanation': explanation,
    'warning_signs': warningSigns.map((w) => w.toJson()).toList(),
    'recommendations': recommendations,
    'source': source.toJson(),
    'analyzed_at': analyzedAt.toIso8601String(),
  };

  /// Deserializes an [AnalysisResult] from a JSON map.
  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final rawLevel = json['risk_level'];
    if (rawLevel is! String) {
      throw const FormatException('AnalysisResult requires a string "risk_level".');
    }
    final level = RiskLevel.fromString(rawLevel);

    final rawScore = json['risk_score'];
    if (rawScore is! int) {
      throw const FormatException('AnalysisResult requires an integer "risk_score".');
    }

    final rawExplanation = json['explanation'];
    if (rawExplanation is! String) {
      throw const FormatException('AnalysisResult requires a string "explanation".');
    }

    final rawSource = json['source'];
    if (rawSource is! String) {
      throw const FormatException('AnalysisResult requires a string "source".');
    }
    final src = AnalysisSource.fromString(rawSource);

    final List<WarningSign> signs = [];
    final rawSigns = json['warning_signs'];
    if (rawSigns != null) {
      if (rawSigns is! List) {
        throw const FormatException('AnalysisResult "warning_signs" must be a list.');
      }
      for (final item in rawSigns) {
        if (item is Map<String, dynamic>) {
          signs.add(WarningSign.fromJson(item));
        } else if (item is String) {
          signs.add(WarningSign.fromTitle(item));
        } else {
          throw const FormatException('Invalid item in "warning_signs". Expected object or string.');
        }
      }
    }

    final List<String> recs = [];
    final rawRecs = json['recommendations'];
    if (rawRecs != null) {
      if (rawRecs is! List) {
        throw const FormatException('AnalysisResult "recommendations" must be a list.');
      }
      for (final item in rawRecs) {
        if (item is String) {
          recs.add(item);
        } else {
          throw const FormatException('All items in "recommendations" must be strings.');
        }
      }
    }

    DateTime? timestamp;
    final rawTime = json['analyzed_at'];
    if (rawTime != null) {
      if (rawTime is! String) {
        throw const FormatException('AnalysisResult "analyzed_at" must be an ISO-8601 string.');
      }
      timestamp = DateTime.tryParse(rawTime);
      if (timestamp == null) {
        throw FormatException('Invalid ISO-8601 date format for "analyzed_at": "$rawTime".');
      }
    }

    return AnalysisResult(
      riskLevel: level,
      riskScore: rawScore,
      explanation: rawExplanation,
      warningSigns: signs,
      recommendations: recs,
      source: src,
      analyzedAt: timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisResult &&
          runtimeType == other.runtimeType &&
          riskLevel == other.riskLevel &&
          riskScore == other.riskScore &&
          explanation == other.explanation &&
          source == other.source;

  @override
  int get hashCode => Object.hash(riskLevel, riskScore, explanation, source);

  @override
  String toString() =>
      'AnalysisResult(level: ${riskLevel.value}, score: $riskScore, source: ${source.value})';
}
