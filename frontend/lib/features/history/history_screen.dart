import 'package:flutter/material.dart';
import '../message_checker/analysis_result_screen.dart';
import '../message_checker/models/models.dart';

/// Data model representing a recorded message scan.
class ScanHistoryItem {
  final String id;
  final String messageText;
  final DateTime timestamp;
  final RiskLevel riskLevel;
  final int riskScore;
  final AnalysisResult? result;

  const ScanHistoryItem({
    required this.id,
    required this.messageText,
    required this.timestamp,
    required this.riskLevel,
    required this.riskScore,
    this.result,
  });
}

/// Formats a DateTime into the approved mockup format: "22 Oct 2026, 9:14 AM"
String formatHistoryTimestamp(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final day = dt.day;
  final month = months[dt.month - 1];
  final year = dt.year;

  final hour24 = dt.hour;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);

  return '$day $month $year, $hour12:$minute $period';
}

/// Filter options for Scan History matching the approved mockup
enum HistoryFilter {
  all('All'),
  dangerous('Dangerous'),
  suspicious('Suspicious'),
  lowRisk('Low Risk');

  final String label;
  const HistoryFilter(this.label);
}

/// Minimal, flat-list Scan History screen matching the approved ScamShield Bharat V2 mockup.
/// Features:
/// - Simple header: "Scan History" (NO second branding row, NO Settings icon)
/// - Compact search bar with clear action
/// - Minimal text-tab filters with thin blue underline (All, Dangerous, Suspicious, Low Risk)
/// - Flat rows separated by thin horizontal dividers (NO individual rounded cards)
/// - Restrained risk pills & scores (Dangerous: red, Suspicious: amber, Low Risk: green)
/// - Distinct empty states: "No scans yet" (with primary "Scan a Message" action) and "No matching scans"
/// - Reuses existing fixed bottom navigation via HomeScreen shell
class HistoryScreen extends StatefulWidget {
  final VoidCallback? onCheckMessage;
  final List<ScanHistoryItem>? initialItems;

  const HistoryScreen({
    super.key,
    this.onCheckMessage,
    this.initialItems,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  HistoryFilter _selectedFilter = HistoryFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query != _searchQuery) {
      setState(() {
        _searchQuery = query;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<ScanHistoryItem> get _items => widget.initialItems ?? const <ScanHistoryItem>[];

  List<ScanHistoryItem> get _filteredItems {
    return _items.where((item) {
      // 1. Filter by RiskLevel
      switch (_selectedFilter) {
        case HistoryFilter.all:
          break;
        case HistoryFilter.dangerous:
          if (item.riskLevel != RiskLevel.dangerous) return false;
          break;
        case HistoryFilter.suspicious:
          if (item.riskLevel != RiskLevel.suspicious) return false;
          break;
        case HistoryFilter.lowRisk:
          if (item.riskLevel != RiskLevel.safe) return false;
          break;
      }

      // 2. Filter by search query
      if (_searchQuery.isNotEmpty) {
        final matchesText = item.messageText.toLowerCase().contains(_searchQuery);
        if (!matchesText) return false;
      }

      return true;
    }).toList();
  }

  void _handleOpenItem(ScanHistoryItem item) {
    final result = item.result ??
        AnalysisResult(
          riskLevel: item.riskLevel,
          riskScore: item.riskScore,
          explanation: item.riskLevel == RiskLevel.dangerous
              ? 'This message triggered multiple high-risk checks. Avoid interacting with it and verify through an official channel.'
              : (item.riskLevel == RiskLevel.suspicious
                  ? 'Several patterns deserve caution. Verify the sender and any requests independently.'
                  : 'The current checks found few warning signs, but automated analysis can miss scams.'),
          source: AnalysisSource.localRuleBased,
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisResultScreen(
          result: result,
          originalMessage: item.messageText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final filtered = _filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Simple Header: "Scan History" (NO branding row, NO settings icon)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 18, 16, 12),
                  child: Center(
                    child: Text(
                      'Scan History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF102A43),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),

                // 2. Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 12, right: 8),
                          child: Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF102A43),
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                              hintText: 'Search previous scans...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                _searchController.clear();
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 3. Filter Tabs (All, Dangerous, Suspicious, Low Risk)
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5EAF2), width: 1),
                    ),
                  ),
                  child: Row(
                    children: HistoryFilter.values.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (_selectedFilter != filter) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              }
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    filter.label,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 2.5,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // 4. Main Body: Empty State or Flat List
                Expanded(
                  child: items.isEmpty
                      ? _buildNoHistoryEmptyState()
                      : (filtered.isEmpty
                          ? _buildNoMatchesEmptyState()
                          : _buildFlatHistoryList(filtered)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Distinct Case 1: No scan history available
  Widget _buildNoHistoryEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No scans yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF102A43),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 320),
              child: Text(
                'Messages you analyze will appear here so you can easily review them later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onCheckMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(Icons.search_rounded, size: 20),
              label: const Text('Scan a Message'),
            ),
          ],
        ),
      ),
    );
  }

  // Distinct Case 2: No search or filter matches
  Widget _buildNoMatchesEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No matching scans',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF102A43),
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try another search or change the selected filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Flat List with rows separated by thin horizontal dividers
  Widget _buildFlatHistoryList(List<ScanHistoryItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(
        color: Color(0xFFE5EAF2),
        height: 1,
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildHistoryRow(item);
      },
    );
  }

  Widget _buildHistoryRow(ScanHistoryItem item) {
    final Color badgeBg;
    final Color badgeColor;
    final String badgeLabel;

    switch (item.riskLevel) {
      case RiskLevel.dangerous:
        badgeBg = const Color(0xFFFEE2E2);
        badgeColor = const Color(0xFFDC2626);
        badgeLabel = 'Dangerous';
        break;
      case RiskLevel.suspicious:
        badgeBg = const Color(0xFFFEF3C7);
        badgeColor = const Color(0xFFD97706);
        badgeLabel = 'Suspicious';
        break;
      case RiskLevel.safe:
        badgeBg = const Color(0xFFDCFCE7);
        badgeColor = const Color(0xFF16A34A);
        badgeLabel = 'Low Risk';
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleOpenItem(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Message preview and timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.messageText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF102A43),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatHistoryTimestamp(item.timestamp),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right: Risk Badge & Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: badgeColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${item.riskScore}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF102A43),
                        ),
                      ),
                      const Text(
                        ' / 100',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Subtle chevron
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
