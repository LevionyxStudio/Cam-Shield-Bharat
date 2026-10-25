import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../splash/splash_screen.dart';

/// Custom vector illustration for Onboarding Screen 1: "Check before you click."
/// Scaled up (~30%) for balanced composition in mobile & web viewports.
class CheckBeforeYouClickIllustration extends StatelessWidget {
  const CheckBeforeYouClickIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Soft ambient circular glow in background
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withValues(alpha: 0.06),
            ),
          ),

          // Central Smartphone Device Card
          Container(
            width: 156,
            height: 224,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFDCE4EE), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryNavy.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top speaker notch
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Placeholder message lines
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 76,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 95,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),

          // Top-Left Warning Alert Badge
          Positioned(
            left: 24,
            top: 28,
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFEE2E2)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.highRisk.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Color(0xFFEF4444),
                size: 28,
              ),
            ),
          ),

          // Bottom-Left Message Envelope Badge
          Positioned(
            left: 36,
            bottom: 34,
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDBEAFE)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                color: AppColors.primaryBlue,
                size: 26,
              ),
            ),
          ),

          // Top-Right Link Chain Badge
          Positioned(
            right: 28,
            top: 34,
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDBEAFE)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.link_rounded,
                color: AppColors.primaryBlue,
                size: 28,
              ),
            ),
          ),

          // Center Foreground: Blue Shield-with-Check Emblem
          const Positioned(
            right: 68,
            bottom: 48,
            child: ShieldWithCheckLogo(
              width: 72,
              height: 84,
              shieldColor: AppColors.primaryBlue,
              checkColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom vector illustration for Onboarding Screen 2: "Your privacy comes first."
/// Scaled up (~30%) for prominent, rich composition.
class PrivacyComesFirstIllustration extends StatelessWidget {
  const PrivacyComesFirstIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Soft ambient circular halo
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withValues(alpha: 0.06),
            ),
          ),

          // Center Padlock Composition
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shackle (curved arch)
              Container(
                width: 66,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(33)),
                  border: Border.all(
                    color: AppColors.primaryBlue,
                    width: 12,
                  ),
                ),
              ),
              // Padlock Body with Shield Icon
              Container(
                width: 122,
                height: 106,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: ShieldWithCheckLogo(
                    width: 48,
                    height: 56,
                    shieldColor: Colors.white,
                    checkColor: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),

          // Top-Left Eye-Off Circular Badge (Privacy)
          Positioned(
            left: 36,
            top: 46,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDBEAFE)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.visibility_off_outlined,
                color: AppColors.primaryBlue,
                size: 26,
              ),
            ),
          ),

          // Top-Right Verified Green Shield Badge (Offline Protection)
          Positioned(
            right: 38,
            top: 52,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDCFCE7)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.likelySafe.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF16A34A),
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
