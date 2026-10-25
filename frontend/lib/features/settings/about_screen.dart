import 'package:flutter/material.dart';
import '../splash/splash_screen.dart';

/// Dedicated About ScamShield Bharat screen matching the approved ScamShield Bharat V2 mockup.
/// Displays:
/// - Shield with check logo
/// - ScamShield Bharat branding
/// - Tagline: "Safer Messages. A Safer India."
/// - Our Mission
/// - How It Works (3 clear steps with outline icons)
/// - Privacy First
class AboutScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const AboutScreen({super.key, this.onBack});

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with back button and centered title
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
                  child: Row(
                    children: [
                      IconButton(
                        key: const Key('about_back_button'),
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          size: 28,
                          color: Color(0xFF102A43),
                        ),
                        onPressed: () => _handleBack(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: 48),
                            child: Text(
                              'About ScamShield Bharat',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF102A43),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable content area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        // Centered Shield Logo
                        const Center(
                          child: ShieldWithCheckLogo(
                            width: 58,
                            height: 66,
                            shieldColor: Color(0xFF2563EB),
                            checkColor: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Branding title: "ScamShield Bharat"
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
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
                        ),

                        const SizedBox(height: 6),

                        // Tagline
                        const Center(
                          child: Text(
                            'Safer Messages. A Safer India.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Section 1: Our Mission
                        const Text(
                          'Our Mission',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF102A43),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ScamShield Bharat helps you identify and avoid scam messages using on-device AI. '
                          'Our goal is to make digital communication safer for everyone in India.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF64748B),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Section 2: How It Works
                        const Text(
                          'How It Works',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF102A43),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildStepItem(
                          icon: Icons.chat_bubble_outline_rounded,
                          text: 'You enter or paste a message',
                        ),
                        const SizedBox(height: 14),
                        _buildStepItem(
                          icon: Icons.psychology_outlined,
                          text: 'The app analyzes it using on-device AI',
                        ),
                        const SizedBox(height: 14),
                        _buildStepItem(
                          icon: Icons.verified_user_outlined,
                          text: 'You get a clear risk assessment',
                        ),

                        const SizedBox(height: 28),

                        // Section 3: Privacy First
                        const Text(
                          'Privacy First',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF102A43),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your messages are analyzed on your device. '
                          'They are not sent to any external server, keeping your information private and secure.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF64748B),
                          ),
                        ),

                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 22,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF102A43),
            ),
          ),
        ),
      ],
    );
  }
}
