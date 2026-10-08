import 'package:DengueLens/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../services/tutorial_service.dart';

/// A modal bottom sheet that explains how to take the best mosquito photo.
///
/// **Usage**:
/// - Call [CameraTipsSheet.showIfNeeded] before opening the camera.
///   It auto-shows only on the first scan and then never again.
/// - Call [CameraTipsSheet.show] to display it unconditionally (e.g. from the
///   help icon in the header so the user can re-read it any time).
class CameraTipsSheet extends StatelessWidget {
  /// When true the "Got it" button does NOT re-mark the tips as seen.
  final bool isManualReplay;

  const CameraTipsSheet({super.key, this.isManualReplay = false});

  // -- Static helpers --------------------------------------------------------

  /// Shows the sheet only if the user has not yet dismissed it via "Got it".
  static Future<void> showIfNeeded(BuildContext context) async {
    if (TutorialService().hasSeenCameraTips) return;
    await show(context, isManualReplay: false);
  }

  /// Always shows the sheet (used by the persistent info icon).
  static Future<void> show(
    BuildContext context, {
    bool isManualReplay = true,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CameraTipsSheet(isManualReplay: isManualReplay),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final tips = [
      _TipData(
        icon: Icons.center_focus_strong_outlined,
        color: const Color(0xFF1ABC9C),
        title: loc.cameraTipDistanceTitle,
        desc: loc.cameraTipDistanceDesc,
      ),
      _TipData(
        icon: Icons.wb_sunny_outlined,
        color: const Color(0xFFF39C12),
        title: loc.cameraTipLightingTitle,
        desc: loc.cameraTipLightingDesc,
      ),
      _TipData(
        icon: Icons.filter_1_outlined,
        color: const Color(0xFF5E35B1),
        title: loc.cameraTipCountTitle,
        desc: loc.cameraTipCountDesc,
      ),
    ];
    return _SheetBody(loc: loc, tips: tips, isManualReplay: isManualReplay);
  }
}

// -----------------------------------------------------------------------------
// Sheet body widget (animated slide-up entrance)
// -----------------------------------------------------------------------------
class _SheetBody extends StatefulWidget {
  final AppLocalizations loc;
  final List<_TipData> tips;
  final bool isManualReplay;

  const _SheetBody({
    required this.loc,
    required this.tips,
    required this.isManualReplay,
  });

  @override
  State<_SheetBody> createState() => _SheetBodyState();
}

class _SheetBodyState extends State<_SheetBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleGotIt() async {
    if (!widget.isManualReplay) {
      await TutorialService().markCameraTipsSeen();
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.only(top: 64),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2ECC71).withValues(alpha: 0.3),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_enhance_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.loc.cameraTipsTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.loc.cameraTipsSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey[500],
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Divider(height: 1, color: Colors.grey[100]),

            // Tips list
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  for (int i = 0; i < widget.tips.length; i++) ...[
                    _TipRow(tip: widget.tips[i], delayMs: i * 80),
                    if (i < widget.tips.length - 1)
                      Divider(
                        height: 24,
                        indent: 56,
                        color: Colors.grey[100],
                      ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Got it button
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + bottomPadding),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleGotIt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    widget.loc.cameraTipsGotIt,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Single tip row with staggered slide-in animation
// -----------------------------------------------------------------------------
class _TipRow extends StatefulWidget {
  final _TipData tip;
  final int delayMs;

  const _TipRow({required this.tip, required this.delayMs});

  @override
  State<_TipRow> createState() => _TipRowState();
}

class _TipRowState extends State<_TipRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.tip.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.tip.icon,
                color: widget.tip.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tip.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.tip.desc,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Data model for a single tip
// -----------------------------------------------------------------------------
class _TipData {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _TipData({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });
}
