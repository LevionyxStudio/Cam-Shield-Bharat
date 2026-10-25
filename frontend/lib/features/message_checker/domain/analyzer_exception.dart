/// Base exception class for failures during message analysis.
class AnalyzerException implements Exception {
  /// Descriptive message explaining the reason for failure.
  final String message;

  /// Optional underlying cause or original error.
  final Object? cause;

  const AnalyzerException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'AnalyzerException: $message (Caused by: $cause)';
    }
    return 'AnalyzerException: $message';
  }
}

/// Thrown when an analysis operation is aborted or cancelled before completing.
class AnalyzerCancelledException extends AnalyzerException {
  const AnalyzerCancelledException([super.message = 'Analysis was cancelled by the user.']);
}

/// Thrown when the requested analyzer engine is uninitialized, missing model weights,
/// or otherwise not ready to process inputs.
class AnalyzerNotReadyException extends AnalyzerException {
  const AnalyzerNotReadyException([super.message = 'Analyzer engine is not ready for inference.']);
}
