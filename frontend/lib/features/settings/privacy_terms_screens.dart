import 'package:flutter/material.dart';

/// Reusable subpage shell for Settings sub-screens (Data Privacy, Permissions, Terms, Privacy Policy).
class _SettingsSubpageShell extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget child;

  const _SettingsSubpageShell({
    required this.title,
    this.onBack,
    required this.child,
  });

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
                // Minimal header matching approved style
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          size: 28,
                          color: Color(0xFF102A43),
                        ),
                        onPressed: () => _handleBack(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 48),
                            child: Text(
                              title,
                              style: const TextStyle(
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

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dedicated Data Privacy explanation screen.
class DataPrivacyScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const DataPrivacyScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return _SettingsSubpageShell(
      title: 'Data Privacy',
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5EAF2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF2563EB),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Your Data Stays on Your Device',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF102A43),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'ScamShield Bharat is designed from the ground up to respect citizen privacy and confidential communications.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildPrivacyPoint(
            icon: Icons.offline_bolt_outlined,
            title: '100% Offline Heuristics',
            description:
                'Message evaluation is performed directly on your device using built-in rule heuristics. No internet connection is needed for scan checks.',
          ),

          const SizedBox(height: 14),

          _buildPrivacyPoint(
            icon: Icons.cloud_off_outlined,
            title: 'Zero Server Data Transmission',
            description:
                'In this version of the app, entered messages, telephone numbers, and links are never sent to external servers or remote AI APIs.',
          ),

          const SizedBox(height: 14),

          _buildPrivacyPoint(
            icon: Icons.memory_outlined,
            title: 'Session-Only Memory Storage',
            description:
                'Analyzed messages remain stored locally in temporary memory during your active session. No persistent remote profile is created.',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPrivacyPoint({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: const Color(0xFF2563EB)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF102A43),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dedicated Permissions screen explaining app permissions honestly.
class PermissionsScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const PermissionsScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return _SettingsSubpageShell(
      title: 'Permissions',
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5EAF2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF2563EB),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Device Permissions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF102A43),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'ScamShield Bharat operates with minimal system permissions. We do not access sensitive hardware or background logs without consent.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildPermissionItem(
            icon: Icons.content_paste_outlined,
            title: 'Clipboard Access',
            status: 'On-Demand',
            statusColor: const Color(0xFF2563EB),
            description:
                'Used solely when you tap the "Paste" button on the Message Checker screen to analyze a message from your clipboard.',
          ),

          const SizedBox(height: 14),

          _buildPermissionItem(
            icon: Icons.notifications_none_outlined,
            title: 'Notifications',
            status: 'Not Required',
            statusColor: const Color(0xFF64748B),
            description:
                'Manual scans do not require push notifications. Future automated SMS alerting features may request notification permission.',
          ),

          const SizedBox(height: 14),

          _buildPermissionItem(
            icon: Icons.network_check_outlined,
            title: 'Internet Access',
            status: 'Optional',
            statusColor: const Color(0xFF16A34A),
            description:
                'The core rule-based analyzer runs 100% locally. Internet connectivity is only needed for checking remote database updates when available.',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String status,
    required Color statusColor,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: const Color(0xFF64748B)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF102A43),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dedicated Terms of Service screen.
class TermsOfServiceScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const TermsOfServiceScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return _SettingsSubpageShell(
      title: 'Terms of Service',
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5EAF2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF2563EB),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terms of Service',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF102A43),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Preliminary Terms • Version 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'By using ScamShield Bharat, you acknowledge and agree to the guidelines and conditions described below.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildTermSection(
            number: '1',
            title: 'Informational Risk Scoring',
            body:
                'ScamShield Bharat provides heuristic risk assessments designed to alert citizens to common scam patterns (e.g., lottery claims, credential harvesting, digital arrest threats). The risk scores are for informational awareness and should not be construed as definitive legal or financial conclusions.',
          ),

          const SizedBox(height: 14),

          _buildTermSection(
            number: '2',
            title: 'Detection Scope & Limitations',
            body:
                'Scammers continually evolve deceptive tactics. A "Low Risk" result indicates that no predefined scam signatures were detected, but does not guarantee that a message or sender is 100% safe. Always verify transactions directly with your official bank or service provider.',
          ),

          const SizedBox(height: 14),

          _buildTermSection(
            number: '3',
            title: 'User Responsibility & Reporting',
            body:
                'You remain solely responsible for any decisions made regarding personal credentials, banking details, or money transfers. Never disclose OTPs or UPI PINs. If you have been victimized by cyber fraud, report immediately to the National Cyber Crime Portal (1930 or cybercrime.gov.in).',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTermSection({
    required String number,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF102A43),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dedicated Privacy Policy screen.
class PrivacyPolicyScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const PrivacyPolicyScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return _SettingsSubpageShell(
      title: 'Privacy Policy',
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5EAF2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFF2563EB),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF102A43),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Effective: October 2026',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'ScamShield Bharat puts user privacy first. We do not monetize citizen data, track behavioral patterns, or transmit confidential communications to the cloud.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildPolicySection(
            title: '1. No Account or Personal Identity Required',
            body:
                'You can use all core message analysis features without registering an account, providing your phone number, or supplying your name.',
          ),

          const SizedBox(height: 14),

          _buildPolicySection(
            title: '2. Local Message Processing',
            body:
                'Texts pasted or entered for analysis are evaluated in-memory on your device by local heuristic rules. They are not transmitted to cloud infrastructure or external third parties.',
          ),

          const SizedBox(height: 14),

          _buildPolicySection(
            title: '3. No Analytics or Third-Party Advertising',
            body:
                'ScamShield Bharat contains zero advertising networks, tracking pixels, or third-party marketing SDKs. We do not sell or monetize citizen usage data.',
          ),

          const SizedBox(height: 14),

          _buildPolicySection(
            title: '4. Contact & Support',
            body:
                'For questions or suggestions regarding ScamShield Bharat, you may consult our open source documentation or reach our developer team via the official repository.',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPolicySection({
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
