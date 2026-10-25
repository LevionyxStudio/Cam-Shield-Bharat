import 'package:flutter/material.dart';
import 'core/storage/onboarding_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/placeholders/placeholder_screens.dart';
import 'features/splash/splash_screen.dart';

class ScamShieldApp extends StatelessWidget {
  final ThemeController? themeController;
  final OnboardingPreferences? onboardingPreferences;

  const ScamShieldApp({
    super.key,
    this.themeController,
    this.onboardingPreferences,
  });

  @override
  Widget build(BuildContext context) {
    final controller = themeController ?? globalThemeController;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'ScamShield Bharat',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: controller.themeMode,
          initialRoute: '/',
          onGenerateInitialRoutes: (String initialRouteName) {
            // Guarantee that every app launch or browser refresh starts at SplashScreen
            // with the animated loading bar, regardless of browser URL history.
            return [
              MaterialPageRoute(
                settings: const RouteSettings(name: '/'),
                builder: (context) => SplashScreen(preferences: onboardingPreferences),
              ),
            ];
          },
          routes: {
            '/': (context) => SplashScreen(preferences: onboardingPreferences),
            '/onboarding': (context) => OnboardingScreen(preferences: onboardingPreferences),
            '/home': (context) => const HomeScreen(),
            '/checker': (context) => const HomeScreen(initialTabIndex: 1),
            '/scan-link': (context) => const ScanLinkScreen(),
            '/scam-alerts': (context) => const ScamAlertsScreen(),
            '/safety-tips': (context) => const SafetyTipsScreen(),
          },
        );
      },
    );
  }
}
