import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/features/message_checker/models/models.dart';

void main() {
  group('RiskLevel Enum', () {
    test('fromString parses valid values correctly', () {
      expect(RiskLevel.fromString('safe'), RiskLevel.safe);
      expect(RiskLevel.fromString('SAFE'), RiskLevel.safe);
      expect(RiskLevel.fromString('suspicious'), RiskLevel.suspicious);
      expect(RiskLevel.fromString('SUSPICIOUS'), RiskLevel.suspicious);
      expect(RiskLevel.fromString('dangerous'), RiskLevel.dangerous);
      expect(RiskLevel.fromString('DANGEROUS'), RiskLevel.dangerous);
    });

    test('fromString throws FormatException on invalid values', () {
      expect(() => RiskLevel.fromString('unknown'), throwsFormatException);
      expect(() => RiskLevel.fromString(''), throwsFormatException);
      expect(() => RiskLevel.fromString('critical'), throwsFormatException);
    });

    test('toJson returns expected string representation', () {
      expect(RiskLevel.safe.toJson(), 'safe');
      expect(RiskLevel.suspicious.toJson(), 'suspicious');
      expect(RiskLevel.dangerous.toJson(), 'dangerous');
    });
  });

  group('AnalysisSource Enum', () {
    test('fromString parses valid sources correctly', () {
      expect(AnalysisSource.fromString('local_on_device'), AnalysisSource.localOnDevice);
      expect(AnalysisSource.fromString('local_rule_based'), AnalysisSource.localRuleBased);
      expect(AnalysisSource.fromString('rule_based'), AnalysisSource.localRuleBased);
      expect(AnalysisSource.fromString('remote_api'), AnalysisSource.remoteApi);
      expect(AnalysisSource.fromString('preset_demo'), AnalysisSource.presetDemo);
      expect(AnalysisSource.fromString('demo'), AnalysisSource.presetDemo);
    });

    test('fromString throws FormatException on unknown source', () {
      expect(() => AnalysisSource.fromString('satellite'), throwsFormatException);
      expect(() => AnalysisSource.fromString(''), throwsFormatException);
    });

    test('toJson returns expected string representation', () {
      expect(AnalysisSource.localOnDevice.toJson(), 'local_on_device');
      expect(AnalysisSource.localRuleBased.toJson(), 'local_rule_based');
      expect(AnalysisSource.remoteApi.toJson(), 'remote_api');
      expect(AnalysisSource.presetDemo.toJson(), 'preset_demo');
    });
  });

  group('WarningSign Model', () {
    test('constructs with valid properties', () {
      const sign = WarningSign(
        code: 'urgent_kyc',
        title: 'Urgent KYC Verification',
        description: 'Demands immediate action under threat of penalty.',
      );
      expect(sign.code, 'urgent_kyc');
      expect(sign.title, 'Urgent KYC Verification');
      expect(sign.description, 'Demands immediate action under threat of penalty.');
    });

    test('fromTitle generates clean code and title', () {
      final sign = WarningSign.fromTitle('Fake CBI Officer Impersonation!');
      expect(sign.code, 'fake_cbi_officer_impersonation');
      expect(sign.title, 'Fake CBI Officer Impersonation!');
    });

    test('fromTitle throws ArgumentError on empty title', () {
      expect(() => WarningSign.fromTitle(''), throwsArgumentError);
      expect(() => WarningSign.fromTitle('   '), throwsArgumentError);
    });

    test('serialization round trip', () {
      const original = WarningSign(
        code: 'otp_harvesting',
        title: 'Request for OTP',
        description: 'Asks user to share one-time password.',
      );
      final json = original.toJson();
      final restored = WarningSign.fromJson(json);

      expect(restored, equals(original));
      expect(restored.code, 'otp_harvesting');
      expect(restored.title, 'Request for OTP');
      expect(restored.description, 'Asks user to share one-time password.');
    });

    test('fromJson throws FormatException on missing or invalid fields', () {
      expect(() => WarningSign.fromJson({'title': 'No code'}), throwsFormatException);
      expect(() => WarningSign.fromJson({'code': 'no_title'}), throwsFormatException);
      expect(() => WarningSign.fromJson({'code': '', 'title': 'empty code'}), throwsFormatException);
      expect(() => WarningSign.fromJson({'code': 'c', 'title': ''}), throwsFormatException);
      expect(
        () => WarningSign.fromJson({'code': 'c', 'title': 't', 'description': 123}),
        throwsFormatException,
      );
    });
  });

  group('AnalysisRequest Model', () {
    test('constructs valid request with required message text', () {
      final request = AnalysisRequest(messageText: 'Your bank account is blocked.');
      expect(request.messageText, 'Your bank account is blocked.');
      expect(request.languageCode, isNull);
      expect(request.sender, isNull);
      expect(request.createdAt, isNotNull);
    });

    test('constructs valid request with all optional metadata', () {
      final timestamp = DateTime.utc(2026, 10, 24, 12, 0, 0);
      final request = AnalysisRequest(
        messageText: 'Police arrest warrant issued.',
        languageCode: 'en',
        sender: '+919876543210',
        createdAt: timestamp,
      );
      expect(request.messageText, 'Police arrest warrant issued.');
      expect(request.languageCode, 'en');
      expect(request.sender, '+919876543210');
      expect(request.createdAt, timestamp);
    });

    test('throws ArgumentError on empty or whitespace message', () {
      expect(() => AnalysisRequest(messageText: ''), throwsArgumentError);
      expect(() => AnalysisRequest(messageText: '    '), throwsArgumentError);
    });

    test('serialization round trip preserves all fields', () {
      final timestamp = DateTime.utc(2026, 10, 24, 15, 30, 0);
      final original = AnalysisRequest(
        messageText: 'Suspicious lottery prize won.',
        languageCode: 'hi',
        sender: 'VK-SBIINB',
        createdAt: timestamp,
      );
      final json = original.toJson();
      final restored = AnalysisRequest.fromJson(json);

      expect(restored.messageText, original.messageText);
      expect(restored.languageCode, original.languageCode);
      expect(restored.sender, original.sender);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromJson throws FormatException on invalid data', () {
      expect(() => AnalysisRequest.fromJson({}), throwsFormatException);
      expect(() => AnalysisRequest.fromJson({'message_text': 12345}), throwsFormatException);
      expect(
        () => AnalysisRequest.fromJson({'message_text': 'Valid', 'created_at': 'not-a-date'}),
        throwsFormatException,
      );
      expect(
        () => AnalysisRequest.fromJson({'message_text': 'Valid', 'created_at': 9999}),
        throwsFormatException,
      );
      expect(
        () => AnalysisRequest.fromJson({'message_text': 'Valid', 'language_code': 12}),
        throwsFormatException,
      );
    });
  });

  group('AnalysisResult Model — Boundary & Validation Tests', () {
    test('accepts lower risk score boundary 0', () {
      final result = AnalysisResult(
        riskLevel: RiskLevel.safe,
        riskScore: 0,
        explanation: 'Harmless message.',
        source: AnalysisSource.localRuleBased,
      );
      expect(result.riskScore, 0);
      expect(result.riskLevel, RiskLevel.safe);
    });

    test('accepts upper risk score boundary 100', () {
      final result = AnalysisResult(
        riskLevel: RiskLevel.dangerous,
        riskScore: 100,
        explanation: 'Extreme fraud threat.',
        source: AnalysisSource.localOnDevice,
      );
      expect(result.riskScore, 100);
      expect(result.riskLevel, RiskLevel.dangerous);
    });

    test('accepts intermediate risk score 50', () {
      final result = AnalysisResult(
        riskLevel: RiskLevel.suspicious,
        riskScore: 50,
        explanation: 'Unverified URL link.',
        source: AnalysisSource.localRuleBased,
      );
      expect(result.riskScore, 50);
    });

    test('rejects negative risk scores with ArgumentError', () {
      expect(
        () => AnalysisResult(
          riskLevel: RiskLevel.safe,
          riskScore: -1,
          explanation: 'Invalid',
          source: AnalysisSource.localRuleBased,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnalysisResult(
          riskLevel: RiskLevel.safe,
          riskScore: -100,
          explanation: 'Invalid',
          source: AnalysisSource.localRuleBased,
        ),
        throwsArgumentError,
      );
    });

    test('rejects scores greater than 100 with ArgumentError', () {
      expect(
        () => AnalysisResult(
          riskLevel: RiskLevel.dangerous,
          riskScore: 101,
          explanation: 'Invalid',
          source: AnalysisSource.localOnDevice,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnalysisResult(
          riskLevel: RiskLevel.dangerous,
          riskScore: 999,
          explanation: 'Invalid',
          source: AnalysisSource.localOnDevice,
        ),
        throwsArgumentError,
      );
    });

    test('warningSigns and recommendations are unmodifiable', () {
      final result = AnalysisResult(
        riskLevel: RiskLevel.safe,
        riskScore: 5,
        explanation: 'Clean',
        warningSigns: [const WarningSign(code: 'c', title: 't')],
        recommendations: ['Do nothing'],
        source: AnalysisSource.localRuleBased,
      );
      expect(() => result.warningSigns.add(const WarningSign(code: 'x', title: 'x')), throwsUnsupportedError);
      expect(() => result.recommendations.add('New rec'), throwsUnsupportedError);
    });
  });

  group('AnalysisResult Model — Serialization Round Trips', () {
    test('complete round trip preserves all fields', () {
      final timestamp = DateTime.utc(2026, 10, 24, 18, 0, 0);
      final original = AnalysisResult(
        riskLevel: RiskLevel.dangerous,
        riskScore: 88,
        explanation: 'Urgent demand for credit card details.',
        warningSigns: [
          const WarningSign(
            code: 'card_demand',
            title: 'Credit Card Request',
            description: 'Requests 16-digit card number and CVV.',
          ),
          WarningSign.fromTitle('Threat of account closure'),
        ],
        recommendations: [
          'Do not share card details or OTP.',
          'Block the sender and report to 1930.',
        ],
        source: AnalysisSource.localOnDevice,
        analyzedAt: timestamp,
      );

      final json = original.toJson();
      final restored = AnalysisResult.fromJson(json);

      expect(restored.riskLevel, original.riskLevel);
      expect(restored.riskScore, original.riskScore);
      expect(restored.explanation, original.explanation);
      expect(restored.source, original.source);
      expect(restored.analyzedAt, original.analyzedAt);
      expect(restored.warningSigns.length, 2);
      expect(restored.warningSigns[0].code, 'card_demand');
      expect(restored.warningSigns[0].description, 'Requests 16-digit card number and CVV.');
      expect(restored.warningSigns[1].title, 'Threat of account closure');
      expect(restored.recommendations, equals(original.recommendations));
    });

    test('supports string items in warning_signs list during deserialization', () {
      final json = {
        'risk_level': 'suspicious',
        'risk_score': 45,
        'explanation': 'Unverified link included.',
        'warning_signs': ['Unshortened link detected', 'Unknown sender domain'],
        'recommendations': ['Do not click unknown links.'],
        'source': 'local_rule_based',
        'analyzed_at': '2026-10-24T18:00:00.000Z',
      };
      final result = AnalysisResult.fromJson(json);

      expect(result.warningSigns.length, 2);
      expect(result.warningSigns[0].title, 'Unshortened link detected');
      expect(result.warningSigns[1].title, 'Unknown sender domain');
    });

    test('fromJson throws FormatException on invalid or missing required values', () {
      // Missing risk_level
      expect(
        () => AnalysisResult.fromJson({
          'risk_score': 50,
          'explanation': 'Test',
          'source': 'local_rule_based',
        }),
        throwsFormatException,
      );

      // Missing risk_score
      expect(
        () => AnalysisResult.fromJson({
          'risk_level': 'safe',
          'explanation': 'Test',
          'source': 'local_rule_based',
        }),
        throwsFormatException,
      );

      // Non-integer risk_score
      expect(
        () => AnalysisResult.fromJson({
          'risk_level': 'safe',
          'risk_score': '50',
          'explanation': 'Test',
          'source': 'local_rule_based',
        }),
        throwsFormatException,
      );

      // Missing explanation
      expect(
        () => AnalysisResult.fromJson({
          'risk_level': 'safe',
          'risk_score': 0,
          'source': 'local_rule_based',
        }),
        throwsFormatException,
      );

      // Missing source
      expect(
        () => AnalysisResult.fromJson({
          'risk_level': 'safe',
          'risk_score': 0,
          'explanation': 'Test',
        }),
        throwsFormatException,
      );

      // Invalid source string
      expect(
        () => AnalysisResult.fromJson({
          'risk_level': 'safe',
          'risk_score': 0,
          'explanation': 'Test',
          'source': 'not_a_valid_source',
        }),
        throwsFormatException,
      );

      // Invalid warning_signs type
      expect(
        () => AnalysisResult.fromJson({
          'risk_level': 'safe',
          'risk_score': 0,
          'explanation': 'Test',
          'source': 'local_rule_based',
          'warning_signs': 'not_a_list',
        }),
        throwsFormatException,
      );

      // Invalid recommendations type
      expect(
        () => AnalysisResult.fromJson({
          'risk_level': 'safe',
          'risk_score': 0,
          'explanation': 'Test',
          'source': 'local_rule_based',
          'recommendations': [123, 456],
        }),
        throwsFormatException,
      );
    });
  });
}
