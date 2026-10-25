import 'package:flutter/material.dart';
import '../../core/storage/onboarding_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../splash/splash_screen.dart';
import 'widgets/onboarding_illustrations.dart';

/// Two-step minimal onboarding flow based on the approved visual reference:
/// 1. "Check before you click."
/// 2. "Your privacy comes first."
///
/// Refinements:
/// - Robust layout handling that eliminates RenderFlex overflows on all viewports
///   (including initial Chrome startup canvas sizing and compact screen heights)
/// - Responsive illustration scaling (~30% enlarged on standard/large displays)
/// - Cohesive vertical spacing between illustration, heading, and supporting text
/// - Crisp typography with optimal line spacing and readability
/// - Stable top bar (Back/Skip) and bottom actions (3-dot indicator + full-width button)
class OnboardingScreen extends StatefulWidget {
  final OnboardingPreferences? preferences;

  const OnboardingScreen({super.key, this.preferences});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboardingAndGoHome() async {
    final prefs = widget.preferences ?? OnboardingPreferences();
    await prefs.setOnboardingCompleted(completed: true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _onNext() {
    if (_currentPage == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboardingAndGoHome();
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF7F9FC);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle pale-blue wave accents in background
          CustomPaint(
            painter: WaveBackgroundPainter(
              waveColor: AppColors.primaryBlue.withValues(alpha: 0.04),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Prevent RenderFlex overflow during transient initial layout frames
                // (e.g. Chrome web canvas initialization with BoxConstraints(w=1.6, h=1.6))
                if (constraints.maxHeight < 200 || constraints.maxWidth < 100) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    // Top Navigation Bar (Fixed consistent positioning)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back Button (Visible only on Screen 2)
                          if (_currentPage > 0)
                            TextButton.icon(
                              onPressed: _onBack,
                              icon: const Icon(Icons.arrow_back_ios_new, size: 14),
                              label: const Text('Back'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryBlue,
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 48),

                          // Skip Button (Visible on both screens)
                          TextButton(
                            onPressed: _completeOnboardingAndGoHome,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text('Skip'),
                          ),
                        ],
                      ),
                    ),

                    // PageView with Two Onboarding Screens
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        children: const [
                          // Screen 1: "Check before you click."
                          _OnboardingPage(
                            illustration: CheckBeforeYouClickIllustration(),
                            heading: 'Check before\nyou click.',
                            supportingText: 'Detect suspicious messages,\nlinks, and offers with ease.',
                          ),

                          // Screen 2: "Your privacy comes first."
                          _OnboardingPage(
                            illustration: PrivacyComesFirstIllustration(),
                            heading: 'Your privacy\ncomes first.',
                            supportingText:
                                'Your messages can be checked\nusing an offline rule-based\nanalyzer on your device.',
                          ),
                        ],
                      ),
                    ),

                    // Bottom Area: Page Indicator Dots & Action Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Three-Dot Page Indicator directly above button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildDot(isActive: _currentPage == 0),
                                const SizedBox(width: 6),
                                _buildDot(isActive: _currentPage == 1),
                                const SizedBox(width: 6),
                                _buildDot(isActive: false),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _onNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: _currentPage == 0
                                    ? const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Next'),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward, size: 18),
                                        ],
                                      )
                                    : const Text('Get started'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 22 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final Widget illustration;
  final String heading;
  final String supportingText;

  const _OnboardingPage({
    required this.illustration,
    required this.heading,
    required this.supportingText,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsively compute max illustration height based on available PageView space
        final availableHeight = constraints.maxHeight;
        final double maxIlluHeight = (availableHeight * 0.48).clamp(140.0, 260.0);

        return Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: maxIlluHeight,
                        maxWidth: 320,
                      ),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: illustration,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      heading,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryNavy,
                        letterSpacing: -0.6,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      supportingText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
