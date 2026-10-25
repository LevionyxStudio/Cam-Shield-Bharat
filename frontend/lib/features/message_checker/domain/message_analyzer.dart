import '../models/models.dart';
import 'analyzer_exception.dart';

export '../models/models.dart';
export 'analyzer_exception.dart';

/// Abstract contract for scam and fraud analysis engines.
///
/// Decouples the user interface from specific evaluation backends, allowing
/// transparent execution across local on-device LLMs, pure-Dart rule heuristics,
/// or remote FastAPI endpoints without UI modifications.
abstract class MessageAnalyzer {
  /// Analyzes the message content encapsulated in [request] and produces an [AnalysisResult].
  ///
  /// Throws [AnalyzerException] if analysis fails due to runtime or engine errors.
  /// Throws [ArgumentError] if the request payload fails validation.
  Future<AnalysisResult> analyze(AnalysisRequest request);
}
