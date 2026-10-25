import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/storage/onboarding_preferences.dart';
import '../../core/theme/app_colors.dart';

/// Minimal, premium light splash screen based on approved visual reference.
/// Features:
/// - 3500ms (3.5s) minimum display duration
/// - Centered logo, ScamShield navy typography, Bharat blue typography, tagline
/// - Subtle pale-blue background wave accents
/// - Slim, rounded animated loading bar with #2563EB indicator and muted "Initializing..." label
/// - Deterministic navigation:
///     First launch: transitions to Onboarding Screen 1 (/onboarding)
///     Returning user: transitions directly to Home dashboard (/home)
class SplashScreen extends StatefulWidget {
  final Duration duration;
  final bool autoNavigate;
  final OnboardingPreferences? preferences;

  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 3500),
    this.autoNavigate = true,
    this.preferences,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAndNavigate();
      }
    });

    if (widget.autoNavigate) {
      _controller.forward();
    }
  }

  Future<void> _checkAndNavigate() async {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    final prefs = widget.preferences ?? OnboardingPreferences();
    final isCompleted = await prefs.isOnboardingCompleted();
    if (!mounted) return;
    if (isCompleted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              waveColor: AppColors.primaryBlue.withValues(alpha: 0.045),
            ),
          ),

          // Centered Brand Content (Logo, Typography, Tagline)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Blue Shield-and-Check Logo
                      const ShieldWithCheckLogo(width: 86, height: 98),

                      const SizedBox(height: 28),

                      // "ScamShield" in Navy #102A43
                      const Text(
                        'ScamShield',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryNavy,
                          letterSpacing: -0.6,
                          height: 1.15,
                        ),
                      ),

                      // "Bharat" in Blue #2563EB
                      const Text(
                        'Bharat',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                          letterSpacing: -0.6,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tagline: "Stay alert. Stay safe."
                      const Text(
                        'Stay alert. Stay safe.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Loading Bar & "Initializing..." label
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Safeguard against extreme micro-viewports (e.g. initial canvas 1.6x1.6)
                if (constraints.maxHeight < 200 || constraints.maxWidth < 100) {
                  return const SizedBox.shrink();
                }

                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0, left: 32.0, right: 32.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, _) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Slim, rounded progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: SizedBox(
                                  height: 4,
                                  child: LinearProgressIndicator(
                                    value: _animation.value,
                                    backgroundColor: const Color(0xFFE2E8F0),
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryBlue,
                                    ),
                                    minHeight: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // "Initializing..." label in muted gray
                              const Text(
                                'Initializing...',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom vector shield logo with internal checkmark.
class ShieldWithCheckLogo extends StatelessWidget {
  final double width;
  final double height;
  final Color shieldColor;
  final Color checkColor;

  const ShieldWithCheckLogo({
    super.key,
    this.width = 86,
    this.height = 98,
    this.shieldColor = AppColors.primaryBlue,
    this.checkColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _ShieldCheckPainter(
        shieldColor: shieldColor,
        checkColor: checkColor,
      ),
    );
  }
}

class _ShieldCheckPainter extends CustomPainter {
  final Color shieldColor;
  final Color checkColor;

  _ShieldCheckPainter({
    required this.shieldColor,
    required this.checkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shield Path
    final path = Path();
    path.moveTo(w * 0.1, h * 0.15);
    path.quadraticBezierTo(w * 0.5, h * 0.02, w * 0.9, h * 0.15);
    path.cubicTo(w * 0.96, h * 0.5, w * 0.8, h * 0.78, w * 0.5, h * 0.98);
    path.cubicTo(w * 0.2, h * 0.78, w * 0.04, h * 0.5, w * 0.1, h * 0.15);
    path.close();

    // Ambient shadow
    final shadowPaint = Paint()
      ..color = shieldColor.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path.shift(const Offset(0, 6)), shadowPaint);

    // Fill Shield
    final shieldPaint = Paint()
      ..color = shieldColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(path, shieldPaint);

    // Checkmark
    final checkPaint = Paint()
      ..color = checkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.092
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final checkPath = Path();
    checkPath.moveTo(w * 0.35, h * 0.49);
    checkPath.lineTo(w * 0.46, h * 0.60);
    checkPath.lineTo(w * 0.65, h * 0.38);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant _ShieldCheckPainter oldDelegate) =>
      oldDelegate.shieldColor != shieldColor || oldDelegate.checkColor != checkColor;
}

/// Subtle pale-blue background curves inspired by the reference splash design.
class WaveBackgroundPainter extends CustomPainter {
  final Color waveColor;

  WaveBackgroundPainter({required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Top-right soft organic wave
    final topWave = Path();
    topWave.moveTo(w * 0.45, 0);
    topWave.quadraticBezierTo(w * 0.72, h * 0.10, w, h * 0.18);
    topWave.lineTo(w, 0);
    topWave.close();
    canvas.drawPath(topWave, paint);

    // Left-middle wave
    final midWave = Path();
    midWave.moveTo(0, h * 0.18);
    midWave.cubicTo(w * 0.26, h * 0.22, w * 0.14, h * 0.36, 0, h * 0.44);
    midWave.close();
    canvas.drawPath(midWave, paint);

    // Bottom-left subtle wave
    final bottomWave = Path();
    bottomWave.moveTo(0, h * 0.64);
    bottomWave.cubicTo(w * 0.36, h * 0.70, w * 0.38, h * 0.86, 0, h * 0.96);
    bottomWave.close();
    canvas.drawPath(bottomWave, paint);
  }

  @override
  bool shouldRepaint(covariant WaveBackgroundPainter oldDelegate) =>
      oldDelegate.waveColor != waveColor;
}
