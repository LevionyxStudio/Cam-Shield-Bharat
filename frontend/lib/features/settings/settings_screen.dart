import 'package:flutter/material.dart';
import '../../core/theme/theme_controller.dart';
import 'about_screen.dart';
import 'privacy_terms_screens.dart';

export 'about_screen.dart';
export 'privacy_terms_screens.dart';

/// Supported subviews in the Settings tab.
enum SettingsSubView {
  main,
  about,
  dataPrivacy,
  permissions,
  terms,
  privacy,
}

/// Minimal Settings screen matching the approved ScamShield Bharat V2 mockup.
/// Features:
/// - Simple centered title: "Settings" (NO branding row, NO settings icon)
/// - Four grouped sections with rounded white cards and thin dividers:
///   1. App Preferences (Appearance, Language)
///   2. Privacy & Security (Data Privacy, Permissions)
///   3. About (About ScamShield Bharat, Terms of Service, Privacy Policy)
///   4. App Info (Version 1.0.0)
/// - Supports in-tab navigation preserving the fixed bottom navigation bar
class SettingsScreen extends StatefulWidget {
  final ThemeController? themeController;
  final SettingsSubView initialView;

  const SettingsScreen({
    super.key,
    this.themeController,
    this.initialView = SettingsSubView.main,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsSubView _currentView;

  @override
  void initState() {
    super.initState();
    _currentView = widget.initialView;
  }

  void _navigateTo(SettingsSubView view) {
    setState(() {
      _currentView = view;
    });
  }

  void _returnToMain() {
    setState(() {
      _currentView = SettingsSubView.main;
    });
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showAppearanceModal(BuildContext context, ThemeController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Appearance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF102A43),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose your preferred display theme.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 18),
                _buildThemeOptionTile(
                  context: bottomSheetContext,
                  controller: controller,
                  title: 'Light mode',
                  subtitle: 'Approved default light theme',
                  icon: Icons.wb_sunny_outlined,
                  mode: ThemeMode.light,
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE5EAF2)),
                _buildThemeOptionTile(
                  context: bottomSheetContext,
                  controller: controller,
                  title: 'Dark mode',
                  subtitle: 'Low-glare dark palette',
                  icon: Icons.dark_mode_outlined,
                  mode: ThemeMode.dark,
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE5EAF2)),
                _buildThemeOptionTile(
                  context: bottomSheetContext,
                  controller: controller,
                  title: 'System default',
                  subtitle: 'Matches your device operating system',
                  icon: Icons.brightness_auto_outlined,
                  mode: ThemeMode.system,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOptionTile({
    required BuildContext context,
    required ThemeController controller,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
  }) {
    final isSelected = controller.themeMode == mode;

    return InkWell(
      key: Key('theme_option_${mode.name}'),
      onTap: () {
        controller.setThemeMode(mode);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF102A43),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: Color(0xFF2563EB),
              ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        Icons.language_outlined,
                        color: Color(0xFF2563EB),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Language Support',
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
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5EAF2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'English (Currently Active)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF102A43),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Multi-language support for regional Indian languages (including Hindi, Punjabi, Bengali, Marathi, and Telugu) is actively under development to protect citizens in their native languages.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        Icons.layers_outlined,
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
                            'ScamShield Bharat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF102A43),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Version 1.0.0 (Build 1)',
                            style: TextStyle(
                              fontSize: 13,
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
                  'ScamShield Bharat V2 • Designed for high-conviction scam awareness and citizen protection across India.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF102A43),
                    side: const BorderSide(color: Color(0xFFE5EAF2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // If viewing a sub-screen, render it directly while keeping the fixed bottom nav shell active
    switch (_currentView) {
      case SettingsSubView.about:
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _returnToMain();
          },
          child: AboutScreen(onBack: _returnToMain),
        );
      case SettingsSubView.dataPrivacy:
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _returnToMain();
          },
          child: DataPrivacyScreen(onBack: _returnToMain),
        );
      case SettingsSubView.permissions:
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _returnToMain();
          },
          child: PermissionsScreen(onBack: _returnToMain),
        );
      case SettingsSubView.terms:
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _returnToMain();
          },
          child: TermsOfServiceScreen(onBack: _returnToMain),
        );
      case SettingsSubView.privacy:
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _returnToMain();
          },
          child: PrivacyPolicyScreen(onBack: _returnToMain),
        );
      case SettingsSubView.main:
        break;
    }

    final controller = widget.themeController ?? globalThemeController;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Simple Header: "Settings" (NO branding row, NO settings icon)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 18, 16, 16),
                  child: Center(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF102A43),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),

                // 2. Scrollable grouped settings sections
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section 1: App Preferences
                        _buildSection(
                          title: 'App Preferences',
                          children: [
                            AnimatedBuilder(
                              animation: controller,
                              builder: (context, _) {
                                return _buildTile(
                                  key: const Key('settings_appearance_tile'),
                                  icon: Icons.wb_sunny_outlined,
                                  title: 'Appearance',
                                  subtitle: _getThemeModeLabel(controller.themeMode),
                                  onTap: () => _showAppearanceModal(context, controller),
                                );
                              },
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFE5EAF2),
                              indent: 52,
                              endIndent: 16,
                            ),
                            _buildTile(
                              key: const Key('settings_language_tile'),
                              icon: Icons.language_outlined,
                              title: 'Language',
                              subtitle: 'English',
                              onTap: () => _showLanguageDialog(context),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Section 2: Privacy & Security
                        _buildSection(
                          title: 'Privacy & Security',
                          children: [
                            _buildTile(
                              key: const Key('settings_data_privacy_tile'),
                              icon: Icons.shield_outlined,
                              title: 'Data Privacy',
                              subtitle: 'Your data stays on your device',
                              onTap: () => _navigateTo(SettingsSubView.dataPrivacy),
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFE5EAF2),
                              indent: 52,
                              endIndent: 16,
                            ),
                            _buildTile(
                              key: const Key('settings_permissions_tile'),
                              icon: Icons.lock_outline,
                              title: 'Permissions',
                              subtitle: 'Manage app permissions',
                              onTap: () => _navigateTo(SettingsSubView.permissions),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Section 3: About
                        _buildSection(
                          title: 'About',
                          children: [
                            _buildTile(
                              key: const Key('settings_about_tile'),
                              icon: Icons.info_outline,
                              title: 'About ScamShield Bharat',
                              subtitle: 'Our mission and how it works',
                              onTap: () => _navigateTo(SettingsSubView.about),
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFE5EAF2),
                              indent: 52,
                              endIndent: 16,
                            ),
                            _buildTile(
                              key: const Key('settings_terms_tile'),
                              icon: Icons.description_outlined,
                              title: 'Terms of Service',
                              onTap: () => _navigateTo(SettingsSubView.terms),
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFE5EAF2),
                              indent: 52,
                              endIndent: 16,
                            ),
                            _buildTile(
                              key: const Key('settings_privacy_policy_tile'),
                              icon: Icons.verified_user_outlined,
                              title: 'Privacy Policy',
                              onTap: () => _navigateTo(SettingsSubView.privacy),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Section 4: App Info
                        _buildSection(
                          title: 'App Info',
                          children: [
                            _buildTile(
                              key: const Key('settings_version_tile'),
                              icon: Icons.layers_outlined,
                              title: 'Version',
                              subtitle: '1.0.0',
                              onTap: () => _showVersionDialog(context),
                            ),
                          ],
                        ),
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

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EAF2), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Key? key,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF102A43),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
