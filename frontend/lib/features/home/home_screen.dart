import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../history/history_screen.dart';
import '../message_checker/message_checker_screen.dart';
import '../settings/settings_screen.dart';
import '../splash/splash_screen.dart';
import 'widgets/dashboard_view.dart';

/// Responsive main navigation shell supporting desktop sidebar (>= 800px)
/// and mobile bottom navigation (< 800px).
/// Exactly four destinations: Home, Check, History, Settings.
/// Settings appears ONLY in this navigation bar (NO Settings icon in Home header).
class HomeScreen extends StatefulWidget {
  final int initialTabIndex;

  const HomeScreen({super.key, this.initialTabIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        final List<Widget> pages = [
          DashboardView(
            onNavigateTab: _setTab,
            onOpenScanLink: () {
              Navigator.pushNamed(context, '/scan-link');
            },
            onOpenScamAlerts: () {
              Navigator.pushNamed(context, '/scam-alerts');
            },
            onOpenSafetyTips: () {
              Navigator.pushNamed(context, '/safety-tips');
            },
          ),
          MessageCheckerScreen(
            onBackToHome: () => _setTab(0),
          ),
          HistoryScreen(
            onCheckMessage: () => _setTab(1),
          ),
          const SettingsScreen(),
        ];

        if (isWide) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F9FC),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _setTab,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  selectedIconTheme: const IconThemeData(color: Color(0xFF2563EB)),
                  unselectedIconTheme: const IconThemeData(color: Color(0xFF64748B)),
                  selectedLabelTextStyle: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: ShieldWithCheckLogo(
                      width: 32,
                      height: 36,
                      shieldColor: AppColors.primaryBlue,
                      checkColor: Colors.white,
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search_rounded),
                      selectedIcon: Icon(Icons.search_rounded),
                      label: Text('Check'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.access_time_rounded),
                      selectedIcon: Icon(Icons.access_time_filled_rounded),
                      label: Text('History'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings_rounded),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFE5EAF2)),
                Expanded(
                  child: pages[_currentIndex],
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: pages[_currentIndex],
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE5EAF2), width: 1),
              ),
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: Colors.white,
                indicatorColor: Colors.transparent,
                elevation: 0,
                height: 64,
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    );
                  }
                  return const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(
                      color: Color(0xFF2563EB),
                      size: 24,
                    );
                  }
                  return const IconThemeData(
                    color: Color(0xFF64748B),
                    size: 24,
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _setTab,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.search_rounded),
                    selectedIcon: Icon(Icons.search_rounded),
                    label: 'Check',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.access_time_rounded),
                    selectedIcon: Icon(Icons.access_time_filled_rounded),
                    label: 'History',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings_rounded),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
