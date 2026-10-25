import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Reusable template for planned supporting screens.
class FeaturePlaceholderScreen extends StatelessWidget {
  final String title;
  final String heading;
  final String description;
  final IconData icon;
  final String actionLabel;
  final VoidCallback? onAction;

  const FeaturePlaceholderScreen({
    super.key,
    required this.title,
    required this.heading,
    required this.description,
    required this.icon,
    this.actionLabel = 'Back',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceSubtle : AppColors.blueLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 40, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.suspicious.withValues(alpha: 0.2) : AppColors.suspiciousLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.suspicious),
                        ),
                        child: const Text(
                          'Planned Feature',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.suspicious,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        heading,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark ? AppColors.darkSecondaryText : AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: onAction ?? () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: Text(actionLabel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScanLinkScreen extends StatelessWidget {
  const ScanLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Scan Link',
      heading: 'URL & Domain Reputation Checker',
      description: 'Comprehensive URL unshortening, suspicious domain heuristics, and phishing database integration will be introduced in an upcoming phase. Message texts with links can already be analyzed in the Message Checker.',
      icon: Icons.link_outlined,
    );
  }
}

class ScamAlertsScreen extends StatelessWidget {
  const ScamAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Scam Alerts',
      heading: 'Community Threat Intelligence',
      description: 'Verified public security advisories on trending cyber threats (digital arrest extortion, APK electricity scams, and task frauds) will be displayed here in an upcoming release.',
      icon: Icons.notifications_active_outlined,
    );
  }
}

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Safety Tips',
      heading: 'Essential Cyber Safety Best Practices',
      description: 'Guidelines to protect yourself: Never share OTPs or PINs over phone or SMS; police and CBI never arrest citizens via video calls; never install APK files sent by unknown numbers.',
      icon: Icons.lightbulb_outline,
    );
  }
}
