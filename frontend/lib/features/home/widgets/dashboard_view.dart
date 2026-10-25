import 'package:flutter/material.dart';
import 'package:scamshield/core/theme/app_colors.dart';
import 'package:scamshield/features/splash/splash_screen.dart';

/// Clean, minimal Home Dashboard reproducing the approved visual reference:
/// - Header with Shield-and-check logo and "ScamShield Bharat" (NO Settings icon in header)
/// - Hero section with bold navy heading and clean supporting text
/// - Pale-blue Safety Banner ("Be aware. Be safer.") with vector device illustration & pagination dots
/// - Quick Actions 2x2 grid with colored icon containers and right chevrons
/// - Truthful Recent Scans empty state with list icon and "View all >" action
class DashboardView extends StatelessWidget {
  final ValueChanged<int> onNavigateTab;
  final VoidCallback onOpenScanLink;
  final VoidCallback onOpenScamAlerts;
  final VoidCallback onOpenSafetyTips;

  const DashboardView({
    super.key,
    required this.onNavigateTab,
    required this.onOpenScanLink,
    required this.onOpenScamAlerts,
    required this.onOpenSafetyTips,
  });

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF7F9FC);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle pale-blue background curve accents
          CustomPaint(
            painter: WaveBackgroundPainter(
              waveColor: AppColors.primaryBlue.withValues(alpha: 0.035),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Header: Shield Logo + "ScamShield Bharat" (NO SETTINGS ICON HERE)
                      Row(
                        children: [
                          const ShieldWithCheckLogo(
                            width: 28,
                            height: 32,
                            shieldColor: AppColors.primaryBlue,
                            checkColor: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text.rich(
                            const TextSpan(
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                              children: [
                                TextSpan(
                                  text: 'ScamShield ',
                                  style: TextStyle(color: Color(0xFF102A43)),
                                ),
                                TextSpan(
                                  text: 'Bharat',
                                  style: TextStyle(color: Color(0xFF2563EB)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // 2. Hero Section
                      const Text(
                        'Stay safe, always.',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF102A43),
                          letterSpacing: -0.6,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Check suspicious messages, links, and offers before you act. All scans run privately on your device.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 3. Pale-Blue Promotional Safety Banner ("Be aware. Be safer.")
                      Container(
                        padding: const EdgeInsets.fromLTRB(18, 18, 14, 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Left Column: Heading, description, pagination dots
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    const TextSpan(
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.4,
                                        height: 1.18,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Be aware.\n',
                                          style: TextStyle(color: Color(0xFF102A43)),
                                        ),
                                        TextSpan(
                                          text: 'Be safer.',
                                          style: TextStyle(color: Color(0xFF2563EB)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Detect scams, fake offers and risky links in seconds.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF64748B),
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Subtle decorative pagination indicators
                                  Row(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2563EB),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFBFDBFE),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFBFDBFE),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Right Column: Custom vector banner illustration
                            const SafetyBannerIllustration(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 4. Quick Actions Section Heading
                      const Text(
                        'Quick actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF102A43),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 2x2 Grid of Quick Action Cards
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = (constraints.maxWidth - 12) / 2;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: cardWidth,
                                child: _buildQuickActionCard(
                                  title: 'Check Message',
                                  subtitle: 'Scan SMS & chat text',
                                  icon: Icons.chat_bubble_outline_rounded,
                                  iconColor: const Color(0xFF2563EB),
                                  iconBgColor: const Color(0xFFE8F1FF),
                                  onTap: () => onNavigateTab(1),
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _buildQuickActionCard(
                                  title: 'Scan Link',
                                  subtitle: 'Verify suspicious URLs',
                                  icon: Icons.link_rounded,
                                  iconColor: const Color(0xFF7C3AED),
                                  iconBgColor: const Color(0xFFF0ECFF),
                                  onTap: onOpenScanLink,
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _buildQuickActionCard(
                                  title: 'Scam Alerts',
                                  subtitle: 'Trending fraud alerts',
                                  icon: Icons.notifications_none_rounded,
                                  iconColor: const Color(0xFFEF4444),
                                  iconBgColor: const Color(0xFFFFE8E8),
                                  onTap: onOpenScamAlerts,
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _buildQuickActionCard(
                                  title: 'Safety Tips',
                                  subtitle: 'Citizen cyber guide',
                                  icon: Icons.lightbulb_outline_rounded,
                                  iconColor: const Color(0xFF16A34A),
                                  iconBgColor: const Color(0xFFE3F8EC),
                                  onTap: onOpenSafetyTips,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // 5. Recent Scans Section Heading & "View all >" Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Scans',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF102A43),
                              letterSpacing: -0.3,
                            ),
                          ),
                          InkWell(
                            onTap: () => onNavigateTab(2),
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View all',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                    color: Color(0xFF2563EB),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Truthful Recent Scans Empty State Card
                      const _RecentScansEmptyState(),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EAF2), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF102A43).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top: Colored rounded icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Bottom row: Title, Subtitle, and Right Chevron
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF102A43),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom vector illustration for the Safety Banner:
/// - Smartphone device outline with red alert badge
/// - Foreground blue shield badge with white checkmark
/// - Ambient decorative blue tick sparks
class SafetyBannerIllustration extends StatelessWidget {
  const SafetyBannerIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      height: 124,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Soft ambient circular glow
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
            ),
          ),

          // Top blue decorative accent sparks
          Positioned(
            left: 12,
            top: 2,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: 3.5,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Positioned(
            right: 14,
            top: 4,
            child: Transform.rotate(
              angle: 0.45,
              child: Container(
                width: 3.5,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Central Smartphone Device Card
          Positioned(
            top: 8,
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                width: 72,
                height: 102,
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top speaker notch
                    Container(
                      width: 18,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Red Warning Triangle Alert Badge
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: const Color(0xFFFECACA), width: 0.8),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Placeholder lines
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Overlapping Blue Shield with Checkmark Emblem
          const Positioned(
            right: 2,
            bottom: 2,
            child: ShieldWithCheckLogo(
              width: 44,
              height: 50,
              shieldColor: AppColors.primaryBlue,
              checkColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Truthful empty state for Recent Scans
class _RecentScansEmptyState extends StatelessWidget {
  const _RecentScansEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF2), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF102A43).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Centered list icon with subtle sparkles
          SizedBox(
            width: 72,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  right: 4,
                  top: 2,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 11,
                    color: const Color(0xFF93C5FD).withValues(alpha: 0.8),
                  ),
                ),
                Positioned(
                  left: 4,
                  bottom: 2,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 11,
                    color: const Color(0xFF93C5FD).withValues(alpha: 0.8),
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.format_list_bulleted_rounded,
                      color: AppColors.primaryBlue,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'No recent scans yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF102A43),
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Messages and links you analyze will appear here for reference.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
