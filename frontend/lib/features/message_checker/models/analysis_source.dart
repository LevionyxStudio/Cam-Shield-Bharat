/// Specifies the engine or origin that produced the analysis result.
///
/// Enables UI transparency, distinguishing local on-device inference
/// from rule-based fallbacks or remote evaluation APIs.
enum AnalysisSource {
  /// Evaluated using a local, quantized on-device AI model (e.g. Qwen / llama.cpp).
  localOnDevice('local_on_device'),

  /// Evaluated using deterministic on-device regex and heuristic pattern matching.
  localRuleBased('local_rule_based'),

  /// Evaluated by connecting to an external analysis service (e.g. FastAPI / Ollama backend).
  remoteApi('remote_api'),

  /// Static or preset demo scenario evaluator for testing and walkthroughs.
  presetDemo('preset_demo');

  const AnalysisSource(this.value);

  /// String identifier used in serialization.
  final String value;

  /// Parses an [AnalysisSource] from a raw string value.
  ///
  /// Throws a [FormatException] if [raw] is unrecognized.
  static AnalysisSource fromString(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'local_on_device':
      case 'localondevice':
        return AnalysisSource.localOnDevice;
      case 'local_rule_based':
      case 'localrulebased':
      case 'rule_based':
        return AnalysisSource.localRuleBased;
      case 'remote_api':
      case 'remoteapi':
      case 'cloud':
        return AnalysisSource.remoteApi;
      case 'preset_demo':
      case 'presetdemo':
      case 'demo':
        return AnalysisSource.presetDemo;
      default:
        throw FormatException(
          'Unknown analysis source: "$raw". Expected local_on_device, '
          'local_rule_based, remote_api, or preset_demo.',
        );
    }
  }

  /// Serializes the source to its JSON string representation.
  String toJson() => value;
}
