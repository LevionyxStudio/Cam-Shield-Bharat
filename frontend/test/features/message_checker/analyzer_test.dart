import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/features/message_checker/domain/message_analyzer.dart';

/// Test fake implementation of [MessageAnalyzer].
class FakeMessageAnalyzer implements MessageAnalyzer {
  final AnalysisResult? resultToReturn;
  final Exception? exceptionToThrow;

  FakeMessageAnalyzer({
    this.resultToReturn,
    this.exceptionToThrow,
  });

  @override
  Future<AnalysisResult> analyze(AnalysisRequest request) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return resultToReturn ??
        AnalysisResult(
          riskLevel: RiskLevel.safe,
          riskScore: 0,
          explanation: 'Message appears safe based on fake evaluator.',
          source: AnalysisSource.presetDemo,
        );
  }
}

void main() {
  group('MessageAnalyzer Interface Contract Tests', () {
    test('analyzes request and returns valid AnalysisResult', () async {
      final analyzer = FakeMessageAnalyzer(
        resultToReturn: AnalysisResult(
          riskLevel: RiskLevel.dangerous,
          riskScore: 92,
          explanation: 'High threat of arrest detected.',
          warningSigns: [
            const WarningSign(
              code: 'police_impersonation',
              title: 'CBI Impersonation Threat',
            ),
          ],
          recommendations: ['Do not send money or join video call.'],
          source: AnalysisSource.localOnDevice,
        ),
      );

      final request = AnalysisRequest(
        messageText: 'CBI police arrest warrant issued against your Aadhaar.',
        sender: 'POLICE-DEPT',
      );

      final result = await analyzer.analyze(request);

      expect(result.riskLevel, RiskLevel.dangerous);
      expect(result.riskScore, 92);
      expect(result.explanation, 'High threat of arrest detected.');
      expect(result.source, AnalysisSource.localOnDevice);
      expect(result.warningSigns.length, 1);
      expect(result.warningSigns.first.code, 'police_impersonation');
      expect(result.recommendations.first, 'Do not send money or join video call.');
    });

    test('propagates AnalyzerException on analysis failure', () async {
      final analyzer = FakeMessageAnalyzer(
        exceptionToThrow: const AnalyzerException('Model runtime failure occurred.'),
      );

      final request = AnalysisRequest(messageText: 'Suspicious text.');

      expect(
        () => analyzer.analyze(request),
        throwsA(isA<AnalyzerException>().having(
          (e) => e.message,
          'message',
          'Model runtime failure occurred.',
        )),
      );
    });

    test('propagates AnalyzerNotReadyException when engine is not initialized', () async {
      final analyzer = FakeMessageAnalyzer(
        exceptionToThrow: const AnalyzerNotReadyException('Model weights not downloaded.'),
      );

      final request = AnalysisRequest(messageText: 'Test message.');

      expect(
        () => analyzer.analyze(request),
        throwsA(isA<AnalyzerNotReadyException>().having(
          (e) => e.message,
          'message',
          'Model weights not downloaded.',
        )),
      );
    });

    test('propagates AnalyzerCancelledException when operation is aborted', () async {
      final analyzer = FakeMessageAnalyzer(
        exceptionToThrow: const AnalyzerCancelledException('User stopped scanning.'),
      );

      final request = AnalysisRequest(messageText: 'Cancelled test.');

      expect(
        () => analyzer.analyze(request),
        throwsA(isA<AnalyzerCancelledException>().having(
          (e) => e.message,
          'message',
          'User stopped scanning.',
        )),
      );
    });

    test('AnalyzerException formats string with optional cause', () {
      const simple = AnalyzerException('Simple error');
      expect(simple.toString(), 'AnalyzerException: Simple error');

      const withCause = AnalyzerException('Wrapped error', 'TimeoutException: 5000ms');
      expect(
        withCause.toString(),
        'AnalyzerException: Wrapped error (Caused by: TimeoutException: 5000ms)',
      );
    });
  });
}
