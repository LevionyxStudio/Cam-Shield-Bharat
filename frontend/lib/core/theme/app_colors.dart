import 'package:flutter/material.dart';

/// ScamShield Bharat color palette for Phase 4 minimal design system.
/// Approved visual reference:
/// - Clean, minimal cybersecurity interface
/// - White backgrounds, soft gray surfaces, navy typography, subtle blue accents
abstract class AppColors {
  // Brand & Accent Colors
  static const Color primaryNavy = Color(0xFF102A43);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color blueLight = Color(0xFFEFF6FF);

  // Light Surfaces & Backgrounds
  static const Color mainBackground = Color(0xFFF7F8FA);
  static const Color homeBackground = Color(0xFFF7F9FC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF17212F);
  static const Color secondaryText = Color(0xFF667085);
  static const Color slateSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE5E7EB);
  static const Color subtleBorder = Color(0xFFE5EAF2);
  static const Color surfaceSubtle = Color(0xFFF1F5F9);

  // Quick Action Icon Containers & Colors
  static const Color iconBgBlue = Color(0xFFE8F1FF);
  static const Color iconBgPurple = Color(0xFFF0ECFF);
  static const Color iconPurple = Color(0xFF7C3AED);
  static const Color iconBgRed = Color(0xFFFFE8E8);
  static const Color iconRed = Color(0xFFEF4444);
  static const Color iconBgGreen = Color(0xFFE3F8EC);
  static const Color iconGreen = Color(0xFF16A34A);

  // Risk Classification Colors
  static const Color highRisk = Color(0xFFDC4545);
  static const Color highRiskLight = Color(0xFFFEF2F2);
  static const Color suspicious = Color(0xFFD99016);
  static const Color suspiciousLight = Color(0xFFFFFBEB);
  static const Color likelySafe = Color(0xFF21865A);
  static const Color likelySafeLight = Color(0xFFF0FDF4);

  // Dark Theme Surfaces & Backgrounds
  static const Color darkBackground = Color(0xFF0B131E);
  static const Color darkSurface = Color(0xFF162235);
  static const Color darkBorder = Color(0xFF223249);
  static const Color darkPrimaryText = Color(0xFFF8FAFC);
  static const Color darkSecondaryText = Color(0xFF94A3B8);
  static const Color darkSurfaceSubtle = Color(0xFF1E293B);
}
