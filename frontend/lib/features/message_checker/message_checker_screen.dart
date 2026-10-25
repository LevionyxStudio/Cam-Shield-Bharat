import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scamshield/core/theme/app_colors.dart';
import 'package:scamshield/features/splash/splash_screen.dart';
import 'analysis_result_screen.dart';
import 'data/rule_based_message_analyzer.dart';
import 'domain/message_analyzer.dart';

/// Clean, minimal Message Checker screen matching approved ScamShield Bharat design:
/// - Header with Shield-and-check logo and "ScamShield Bharat" (NO settings icon in header)
/// - Title "Check a Message" and clear supporting subtitle
/// - Guidance banner ("Not sure if it's a scam?" with custom vector magnifying glass illustration)
/// - Message Input Card:
///     * Header with "Enter message text" and [Paste] button
///     * Multiline input with "Paste or type the message here..." and "0/2000" character counter
///     * Secondary action buttons: [Try an example] and [Clear]
///     * Primary action: Full-width blue [Analyze message ->] button with validation
/// - Privacy card with green shield icon ("Your privacy matters")
class MessageCheckerScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  final MessageAnalyzer analyzer;

  const MessageCheckerScreen({
    super.key,
    this.onBackToHome,
    this.analyzer = const RuleBasedMessageAnalyzer(),
  });

  @override
  State<MessageCheckerScreen> createState() => _MessageCheckerScreenState();
}

class _MessageCheckerScreenState extends State<MessageCheckerScreen> {
  final TextEditingController _textController = TextEditingController();
  FocusNode? _focusNode;
  bool _isFocused = false;
  bool _isAnalyzing = false;
  String? _errorMessage;

  FocusNode get _effectiveFocusNode {
    if (_focusNode == null) {
      _focusNode = FocusNode();
      _focusNode!.addListener(_onFocusChange);
    }
    return _focusNode!;
  }

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode;
  }

  void _onFocusChange() {
    if (!mounted) return;
    if (_focusNode != null && _isFocused != _focusNode!.hasFocus) {
      setState(() {
        _isFocused = _focusNode!.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode?.removeListener(_onFocusChange);
    _focusNode?.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handlePaste() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null && data!.text!.isNotEmpty) {
        setState(() {
          _textController.text = data.text!;
          _errorMessage = null;
        });
      }
    } catch (_) {
      // Gracefully handle unsupported clipboard access
    }
  }

  Future<void> _handleAnalyze() async {
    if (_isAnalyzing) return;

    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter or paste a message to analyze.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isAnalyzing = true;
    });

    try {
      final request = AnalysisRequest(messageText: text);
      final result = await widget.analyzer.analyze(request);

      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
      });

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisResultScreen(
            result: result,
            request: request,
            originalMessage: text,
          ),
        ),
      );
    } on AnalyzerException catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _errorMessage = e.message;
      });
    } on ArgumentError catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _errorMessage = e.message?.toString() ?? 'Invalid message content.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'An error occurred during analysis. Please try again.';
      });
    }
  }

  void _showExamplePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select a Demonstration Message',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF102A43),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose an example scenario to populate the input box:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 14),
                _buildExampleOption(
                  ctx,
                  title: 'Bank KYC Account Suspension',
                  category: 'Urgent Threat + Phishing Link',
                  sampleText:
                      'Dear customer, your SBI account is locked. Update KYC at bit.ly/sbi-kyc immediately to avoid permanent deactivation.',
                ),
                const SizedBox(height: 10),
                _buildExampleOption(
                  ctx,
                  title: 'Lottery Prize with Advance Fee',
                  category: 'Fake Prize / Upfront Fee',
                  sampleText:
                      'Congrats! You have won Rs 25,00,000 in KBC Draw. Pay Rs 2,500 registration fee to claim your prize money.',
                ),
                const SizedBox(height: 10),
                _buildExampleOption(
                  ctx,
                  title: 'Legitimate Bank Transaction Alert',
                  category: 'Benign Alert Counterexample',
                  sampleText:
                      'Your account XX1234 credited with INR 5,000 on 24-Oct. Available balance INR 25,000. Never share your OTP with anyone.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExampleOption(
    BuildContext ctx, {
    required String title,
    required String category,
    required String sampleText,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        setState(() {
          _textController.text = sampleText;
          _errorMessage = null;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 2),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF7F9FC);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle pale-blue background curve accents
          CustomPaint(
            painter: WaveBackgroundPainter(
              waveColor: AppColors.primaryBlue.withValues(alpha: 0.035),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Header: Shield Logo + "ScamShield Bharat" (NO SETTINGS ICON HERE)
                      Row(
                        children: [
                          const ShieldWithCheckLogo(
                            width: 28,
                            height: 32,
                            shieldColor: AppColors.primaryBlue,
                            checkColor: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text.rich(
                            const TextSpan(
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
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
                        ],
                      ),

                      const SizedBox(height: 22),

                      // 2. Title & Supporting Text
                      const Text(
                        'Check a Message',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF102A43),
                          letterSpacing: -0.6,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Scan suspicious SMS, WhatsApp messages, emails, or any text before you act.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 3. Compact Pale-Blue Guidance Banner
                      Container(
                        padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            // Left Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Not sure if it's a scam?",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF102A43),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Paste the message below\nand get an instant analysis.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF64748B),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 8),

                            // Right custom vector illustration
                            GuidanceBannerIllustration(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 4. Message Input Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE5EAF2), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF102A43).withValues(alpha: 0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Input Header Row: "Enter message text" + [Paste]
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Enter message text',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF102A43),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                Material(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    onTap: _handlePaste,
                                    borderRadius: BorderRadius.circular(8),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.content_paste_rounded,
                                            size: 15,
                                            color: Color(0xFF2563EB),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'Paste',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Multiline Input Text Area with Counter
                            // Styled with subtle #F7F9FC background and borderless unfocused state
                            // to eliminate the nested "box-in-a-box" double-border clutter and dark outlines.
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F9FC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _errorMessage != null
                                      ? const Color(0xFFEF4444)
                                      : (_isFocused
                                          ? const Color(0xFF2563EB)
                                          : Colors.transparent),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      inputDecorationTheme: const InputDecorationTheme(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        filled: false,
                                        fillColor: Colors.transparent,
                                      ),
                                    ),
                                    child: TextField(
                                      focusNode: _effectiveFocusNode,
                                      controller: _textController,
                                      maxLines: 5,
                                      maxLength: 2000,
                                      buildCounter: (context,
                                              {required currentLength,
                                              required isFocused,
                                              maxLength}) =>
                                          null,
                                      onChanged: (val) {
                                        setState(() {
                                          if (_errorMessage != null) _errorMessage = null;
                                        });
                                      },
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF102A43),
                                        height: 1.45,
                                      ),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        hintText: 'Paste or type the message here...',
                                        hintStyle: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 14,
                                        ),
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      '${_textController.text.length}/2000',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Validation error alert if empty
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFECACA)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded,
                                        size: 16, color: Color(0xFFEF4444)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFEF4444),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 14),

                            // Secondary Actions Row: [Try an example] + [Clear]
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _showExamplePicker,
                                    icon: const Icon(
                                      Icons.article_outlined,
                                      size: 18,
                                      color: Color(0xFF2563EB),
                                    ),
                                    label: const Text('Try an example'),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF8FAFC),
                                      foregroundColor: const Color(0xFF102A43),
                                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _textController.clear();
                                        _errorMessage = null;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: Color(0xFF64748B),
                                    ),
                                    label: const Text('Clear'),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF8FAFC),
                                      foregroundColor: const Color(0xFF64748B),
                                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Primary Action Button: "Analyze message ->"
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                key: const Key('analyze_message_button'),
                                onPressed: _isAnalyzing ? null : _handleAnalyze,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(0xFF93C5FD),
                                  disabledForegroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: _isAnalyzing
                                    ? const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text('Analyzing message...'),
                                        ],
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.search_rounded, size: 20),
                                          SizedBox(width: 8),
                                          Text('Analyze message'),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward_rounded, size: 18),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 5. White Privacy Information Card with Pale-Green Shield Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5EAF2), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF102A43).withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F8EC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.shield_outlined,
                                  color: Color(0xFF16A34A),
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your privacy matters',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF102A43),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'All scans run privately on your device.\nYour messages are not stored or shared.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF64748B),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom vector illustration for the Guidance Banner:
/// - Message bubble card outline with subtle lines
/// - Prominent blue magnifying glass in foreground
/// - Decorative ambient blue spark ticks
class GuidanceBannerIllustration extends StatelessWidget {
  const GuidanceBannerIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Blue spark ticks
          Positioned(
            right: 28,
            top: 2,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 3,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 14,
            child: Transform.rotate(
              angle: 0.7,
              child: Container(
                width: 3,
                height: 7,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 4,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: 2.5,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Message Card
          Positioned(
            left: 6,
            top: 12,
            child: Transform.rotate(
              angle: -0.06,
              child: Container(
                width: 72,
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF93C5FD),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 34,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFDBFE),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 20,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFDBFE),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Foreground Magnifying Glass
          Positioned(
            right: 8,
            bottom: 6,
            child: SizedBox(
              width: 40,
              height: 40,
              child: CustomPaint(
                painter: _MagnifyingGlassPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MagnifyingGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final center = Offset(w * 0.42, h * 0.42);
    final radius = w * 0.32;

    // Subtle glass tint
    final glassPaint = Paint()
      ..color = const Color(0xFFEFF6FF).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, glassPaint);

    // Blue rim
    final rimPaint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, rimPaint);

    // Handle pointing down-right
    final handlePaint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final start = Offset(
      center.dx + radius * 0.707,
      center.dy + radius * 0.707,
    );
    final end = Offset(w * 0.94, h * 0.94);
    canvas.drawLine(start, end, handlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
