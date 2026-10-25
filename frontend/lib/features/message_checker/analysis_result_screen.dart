import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../splash/splash_screen.dart';
import 'models/models.dart';

/// Clean, responsive Analysis Results screen for ScamShield Bharat V2.
/// Matches the approved 3-state design system:
/// 1. Dangerous (Strong scam indicators detected)
/// 2. Suspicious (Some warning signs detected)
/// 3. Safe / No strong indicators detected
class AnalysisResultScreen extends StatelessWidget {
  final AnalysisResult result;
  final AnalysisRequest? request;
  final String? originalMessage;
  final VoidCallback? onScanAnother;
  final VoidCallback? onViewHistory;
  final ValueChanged<int>? onNavigateTab;

  const AnalysisResultScreen({
    super.key,
    required this.result,
    this.request,
    this.originalMessage,
    this.onScanAnother,
    this.onViewHistory,
    this.onNavigateTab,
  });

  String get _displayMessage {
    if (request != null && request!.messageText.isNotEmpty) {
      return request!.messageText;
    }
    if (originalMessage != null && originalMessage!.trim().isNotEmpty) {
      return originalMessage!.trim();
    }
    return '';
  }

  IconData _getWarningSignIcon(String code, String title, RiskLevel level) {
    final lower = '$code $title'.toLowerCase();
    if (lower.contains('bank') ||
        lower.contains('sbi') ||
        lower.contains('financial') ||
        lower.contains('impersonat')) {
      return Icons.account_balance_rounded;
    }
    if (lower.contains('urgency') ||
        lower.contains('urgent') ||
        lower.contains('immediate') ||
        lower.contains('time') ||
        lower.contains('clock')) {
      return Icons.access_time_filled_rounded;
    }
    if (lower.contains('otp') ||
        lower.contains('sensitive') ||
        lower.contains('credential') ||
        lower.contains('password') ||
        lower.contains('pin')) {
      return Icons.error_rounded;
    }
    if (lower.contains('link') ||
        lower.contains('url') ||
        lower.contains('website') ||
        lower.contains('http')) {
      return lower.contains('no ')
          ? Icons.link_off_rounded
          : Icons.link_rounded;
    }
    if (lower.contains('suspension') ||
        lower.contains('block') ||
        lower.contains('threat') ||
        lower.contains('arrest') ||
        lower.contains('cbi')) {
      return Icons.shield_rounded;
    }
    if (lower.contains('prize') ||
        lower.contains('reward') ||
        lower.contains('lottery') ||
        lower.contains('won') ||
        lower.contains('cash')) {
      return Icons.emoji_events_rounded;
    }
    if (lower.contains('official') ||
        lower.contains('source') ||
        lower.contains('unverified')) {
      return Icons.gpp_maybe_rounded;
    }
    if (level == RiskLevel.safe) {
      if (lower.contains('regular') || lower.contains('notification')) {
        return Icons.notifications_active_rounded;
      }
      return Icons.check_circle_rounded;
    }
    return Icons.warning_rounded;
  }

  IconData _getRecommendationIcon(String rec) {
    final lower = rec.toLowerCase();
    if (lower.contains('share') ||
        lower.contains('personal') ||
        lower.contains('otp') ||
        lower.contains('password') ||
        lower.contains('credential')) {
      return Icons.person_outline_rounded;
    }
    if (lower.contains('link') ||
        lower.contains('click') ||
        lower.contains('url')) {
      return Icons.link_off_rounded;
    }
    if (lower.contains('bank') ||
        lower.contains('app') ||
        lower.contains('website') ||
        lower.contains('official')) {
      return Icons.verified_outlined;
    }
    if (lower.contains('report') ||
        lower.contains('block') ||
        lower.contains('sender')) {
      return Icons.block_rounded;
    }
    if (lower.contains('proceed') ||
        lower.contains('normally') ||
        lower.contains('safe')) {
      return Icons.check_circle_outline_rounded;
    }
    if (lower.contains('ignore') || lower.contains('delete')) {
      return Icons.delete_outline_rounded;
    }
    return Icons.shield_outlined;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Resolve State Colors and Typography according to RiskLevel
    final Color statusBg;
    final Color statusBorderColor;
    final Color statusBadgeColor;
    final IconData statusIcon;
    final String statusHeading;
    final Color statusTextColor;
    final String statusSubtitle;

    final Color ringColor;
    final Color explanationBannerBg;
    final Color explanationBannerBorder;

    final Color signIconBg;
    final Color signIconColor;
    final String signsHeaderTitle;
    final IconData signsHeaderIcon;
    final Color signsHeaderIconColor;

    switch (result.riskLevel) {
      case RiskLevel.dangerous:
        statusBg = const Color(0xFFFEF2F2);
        statusBorderColor = const Color(0xFFFECACA);
        statusBadgeColor = const Color(0xFFDC2626);
        statusIcon = Icons.error_outline_rounded;
        statusHeading = 'Dangerous';
        statusTextColor = const Color(0xFFDC2626);
        statusSubtitle = 'Strong scam indicators detected.';

        ringColor = const Color(0xFFDC2626);
        explanationBannerBg = const Color(0xFFFDE8E8);
        explanationBannerBorder = const Color(0xFFFECACA);

        signIconBg = const Color(0xFFFEE2E2);
        signIconColor = const Color(0xFFDC2626);
        signsHeaderTitle = 'Detected Warning Signs';
        signsHeaderIcon = Icons.warning_amber_rounded;
        signsHeaderIconColor = const Color(0xFFDC2626);
        break;

      case RiskLevel.suspicious:
        statusBg = const Color(0xFFFFFBEB);
        statusBorderColor = const Color(0xFFFDE68A);
        statusBadgeColor = const Color(0xFFD97706);
        statusIcon = Icons.warning_amber_rounded;
        statusHeading = 'Suspicious';
        statusTextColor = const Color(0xFFB45309);
        statusSubtitle = 'Some warning signs detected.';

        ringColor = const Color(0xFFD97706);
        explanationBannerBg = const Color(0xFFFFF2D6);
        explanationBannerBorder = const Color(0xFFFDE68A);

        signIconBg = const Color(0xFFFEF3C7);
        signIconColor = const Color(0xFFD97706);
        signsHeaderTitle = 'Detected Warning Signs';
        signsHeaderIcon = Icons.warning_amber_rounded;
        signsHeaderIconColor = const Color(0xFFD97706);
        break;

      case RiskLevel.safe:
        statusBg = const Color(0xFFF0FDF4);
        statusBorderColor = const Color(0xFFBBF7D0);
        statusBadgeColor = const Color(0xFF16A34A);
        statusIcon = Icons.verified_user_rounded;
        statusHeading = 'No strong indicators detected';
        statusTextColor = const Color(0xFF15803D);
        statusSubtitle = 'No clear scam indicators found.';

        ringColor = const Color(0xFF16A34A);
        explanationBannerBg = const Color(0xFFE3F8EC);
        explanationBannerBorder = const Color(0xFFBBF7D0);

        signIconBg = const Color(0xFFDCFCE7);
        signIconColor = const Color(0xFF16A34A);
        signsHeaderTitle = 'Detected Information';
        signsHeaderIcon = Icons.info_outline_rounded;
        signsHeaderIconColor = const Color(0xFF2563EB);
        break;
    }

    final messageText = _displayMessage;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Clean App Header: ScamShield Bharat branding
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ShieldWithCheckLogo(
                    width: 20,
                    height: 23,
                    shieldColor: AppColors.primaryBlue,
                    checkColor: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'ScamShield ',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryNavy,
                            letterSpacing: -0.3,
                          ),
                        ),
                        TextSpan(
                          text: 'Bharat',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Navigation bar row: Back button [<] and "Analysis Result"
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 16, 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 28,
                            color: Color(0xFF102A43),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Analysis Result',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF102A43),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Scrollable Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card 1: Result Status Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: statusBorderColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: statusBadgeColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    statusIcon,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      statusHeading,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: statusTextColor,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      statusSubtitle,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF475569),
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Card 2: Risk Score & Explanation
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE5EAF2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF102A43)
                                    .withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Risk Score',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF102A43),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Rule-based heuristic assessment • Not a guarantee of safety',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 108,
                                height: 108,
                                child: CustomPaint(
                                  painter: _RiskScoreGaugePainter(
                                    scorePercent: (result.riskScore / 100.0)
                                        .clamp(0.0, 1.0),
                                    progressColor: ringColor,
                                    trackColor: const Color(0xFFEDF2F7),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${result.riskScore}',
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF102A43),
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const Text(
                                          '/ 100',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: explanationBannerBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: explanationBannerBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  result.explanation,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF334155),
                                    height: 1.45,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Card 3: Analyzed Message Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE5EAF2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF102A43)
                                    .withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Analyzed Message',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF102A43),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  if (messageText.isNotEmpty)
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(text: messageText),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Message copied to clipboard',
                                              ),
                                              duration: Duration(seconds: 2),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.copy_rounded,
                                            size: 18,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SelectableText(
                                messageText.isNotEmpty
                                    ? messageText
                                    : '(No message text supplied)',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: messageText.isNotEmpty
                                      ? const Color(0xFF102A43)
                                      : const Color(0xFF94A3B8),
                                  height: 1.45,
                                  fontStyle: messageText.isNotEmpty
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Card 4: Detected Warning Signs / Detected Information
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE5EAF2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF102A43)
                                    .withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    signsHeaderIcon,
                                    size: 20,
                                    color: signsHeaderIconColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    signsHeaderTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF102A43),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (result.warningSigns.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'No specific warning signs identified in this message.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: result.warningSigns.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                    color: Color(0xFFF1F5F9),
                                    height: 14,
                                    thickness: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    final sign = result.warningSigns[index];
                                    final signIcon = _getWarningSignIcon(
                                      sign.code,
                                      sign.title,
                                      result.riskLevel,
                                    );
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: signIconBg,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                signIcon,
                                                size: 17,
                                                color: signIconColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              sign.title,
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF102A43),
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                            size: 18,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Card 5: Recommended Actions
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE5EAF2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF102A43)
                                    .withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.verified_user_rounded,
                                    size: 20,
                                    color: Color(0xFF2563EB),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Recommended Actions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF102A43),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (result.recommendations.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'No additional recommendations.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: result.recommendations.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                    color: Color(0xFFF1F5F9),
                                    height: 14,
                                    thickness: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    final rec = result.recommendations[index];
                                    final recIcon = _getRecommendationIcon(rec);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFEFF6FF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                recIcon,
                                                size: 17,
                                                color: Color(0xFF2563EB),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              rec,
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF102A43),
                                                height: 1.35,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                            size: 18,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Bottom Actions: [Scan Another Message] & [View in History]
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (onScanAnother != null) {
                                onScanAnother!();
                              } else if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/checker',
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            label: const Text('Scan Another Message'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (onViewHistory != null) {
                                onViewHistory!();
                              } else {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(
                                      initialTabIndex: 2,
                                    ),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2563EB),
                              side: const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            icon: const Icon(
                              Icons.article_outlined,
                              size: 20,
                              color: Color(0xFF2563EB),
                            ),
                            label: const Text('View in History'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE5EAF2), width: 1),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: Colors.transparent,
            elevation: 0,
            height: 64,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2563EB),
                );
              }
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                  color: Color(0xFF2563EB),
                  size: 24,
                );
              }
              return const IconThemeData(
                color: Color(0xFF64748B),
                size: 24,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: 1, // Check destination is active
            onDestinationSelected: (index) {
              if (onNavigateTab != null) {
                onNavigateTab!(index);
                return;
              }
              if (index == 1) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(initialTabIndex: index),
                  ),
                  (route) => false,
                );
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_rounded),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Check',
              ),
              NavigationDestination(
                icon: Icon(Icons.access_time_rounded),
                selectedIcon: Icon(Icons.access_time_filled_rounded),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the circular risk score progress gauge
class _RiskScoreGaugePainter extends CustomPainter {
  final double scorePercent;
  final Color progressColor;
  final Color trackColor;

  _RiskScoreGaugePainter({
    required this.scorePercent,
    required this.progressColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    const strokeWidth = 9.0;

    // Track Paint
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc Paint
    if (scorePercent > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * scorePercent.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RiskScoreGaugePainter oldDelegate) =>
      oldDelegate.scorePercent != scorePercent ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.trackColor != trackColor;
}
