import 'package:DengueLens/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../services/tutorial_service.dart';

/// Type of a tutorial step – controls what kind of UI is rendered.
enum _StepType {
  /// Dark overlay with spotlight cutout on a widget.
  spotlight,

  /// Full-screen informational card (no target widget).
  infoCard,
}

/// Data class representing a single tutorial step.
class _TutorialStep {
  final String title;
  final String description;
  final IconData icon;

  /// Only used for [_StepType.spotlight].
  final GlobalKey? targetKey;

  /// Only used for [_StepType.infoCard].
  final Color? accentColor;

  /// Optional extra tip shown below the description (e.g. the delete tip).
  final String? tipText;
  final IconData? tipIcon;

  const _TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    this.targetKey,
    this.accentColor,
    this.tipText,
    this.tipIcon,
  });

  _StepType get type =>
      targetKey != null ? _StepType.spotlight : _StepType.infoCard;
}

/// Full-screen overlay that guides the user through the app features.
class TutorialOverlay extends StatefulWidget {
  /// GlobalKey attached to the Scan button.
  final GlobalKey scanKey;

  /// GlobalKey attached to the Upload button.
  final GlobalKey uploadKey;

  /// GlobalKey attached to the bottom NavigationBar.
  final GlobalKey navBarKey;

  /// GlobalKey attached to the replay-tutorial FAB.
  final GlobalKey fabKey;

  /// Called when the tutorial is dismissed (completed or skipped).
  final VoidCallback onDismiss;

  const TutorialOverlay({
    super.key,
    required this.scanKey,
    required this.uploadKey,
    required this.navBarKey,
    required this.fabKey,
    required this.onDismiss,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late final List<_TutorialStep> _steps;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  bool _stepsBuilt = false; // guard so _buildSteps only runs once

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_stepsBuilt) {
      _buildSteps(context);
      _stepsBuilt = true;
    }
  }

  void _buildSteps(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    _steps = [
      // ── Welcome ──────────────────────────────────────────────────────────
      _TutorialStep(
        title: loc.tutorialWelcomeTitle,
        description: loc.tutorialWelcomeDesc,
        icon: Icons.waving_hand_rounded,
        accentColor: const Color(0xFF2ECC71),
      ),

      // ── Scan Button ───────────────────────────────────────────────────────
      _TutorialStep(
        title: loc.tutorialScanTitle,
        description: loc.tutorialScanDesc,
        icon: Icons.camera_alt_outlined,
        targetKey: widget.scanKey,
        accentColor: const Color(0xFF2ECC71),
      ),

      // ── Upload Button ─────────────────────────────────────────────────────
      _TutorialStep(
        title: loc.tutorialUploadTitle,
        description: loc.tutorialUploadDesc,
        icon: Icons.photo_library_outlined,
        targetKey: widget.uploadKey,
        accentColor: const Color(0xFF2ECC71),
      ),

      // ── NavBar highlight ──────────────────────────────────────────────────
      _TutorialStep(
        title: loc.tutorialNavTitle,
        description: loc.tutorialNavDesc,
        icon: Icons.explore_outlined,
        targetKey: widget.navBarKey,
        accentColor: const Color(0xFF2ECC71),
      ),

      // ── History info card ─────────────────────────────────────────────────
      _TutorialStep(
        title: loc.tutorialHistoryTitle,
        description: loc.tutorialHistoryDesc,
        icon: Icons.history_rounded,
        accentColor: const Color(0xFF3498DB),
        tipText: loc.tutorialHistoryTip,
        tipIcon: Icons.swipe_left_alt_rounded,
      ),

      // ── Point Map info card ───────────────────────────────────────────────
      _TutorialStep(
        title: loc.tutorialMapTitle,
        description: loc.tutorialMapDesc,
        icon: Icons.map_rounded,
        accentColor: const Color(0xFF9B59B6),
        tipText: loc.tutorialMapTip,
        tipIcon: Icons.touch_app_rounded,
      ),

      // ── Risk Assessment info card ─────────────────────────────────────────
      _TutorialStep(
        title: loc.tutorialRiskTitle,
        description: loc.tutorialRiskDesc,
        icon: Icons.health_and_safety_rounded,
        accentColor: const Color(0xFFE67E22),
        tipText: loc.tutorialRiskTip,
        tipIcon: Icons.assignment_turned_in_rounded,
      ),

      // ── Library info card ─────────────────────────────────────────────────
      _TutorialStep(
        title: loc.tutorialLibraryTitle,
        description: loc.tutorialLibraryDesc,
        icon: Icons.local_library_rounded,
        accentColor: const Color(0xFF1ABC9C),
        tipText: loc.tutorialLibraryTip,
        tipIcon: Icons.menu_book_rounded,
      ),

      // ── Replay FAB ────────────────────────────────────────────────────────
      _TutorialStep(
        title: loc.tutorialReplayTitle,
        description: loc.tutorialReplayDesc,
        icon: Icons.school_outlined,
        targetKey: widget.fabKey,
        accentColor: const Color(0xFF2ECC71),
      ),
    ];
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Returns the bounding rectangle of a widget identified by its [GlobalKey].
  Rect? _getTargetRect(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final offset = renderObject.localToGlobal(Offset.zero);
      return offset & renderObject.size;
    }
    return null;
  }

  void _goToStep(int step) {
    _animController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _currentStep = step);
      _animController.forward();
    });
  }

  void _next() {
    if (_currentStep < _steps.length - 1) {
      _goToStep(_currentStep + 1);
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  void _finish() {
    TutorialService().markTutorialSeen();
    _animController.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final isLastStep = _currentStep == _steps.length - 1;

    if (step.type == _StepType.infoCard) {
      return _buildInfoCardStep(step, isLastStep);
    } else {
      return _buildSpotlightStep(step, isLastStep);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Spotlight overlay step
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSpotlightStep(_TutorialStep step, bool isLastStep) {
    final targetRect = step.targetKey != null
        ? _getTargetRect(step.targetKey!)
        : null;
    final screenSize = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Dark backdrop with spotlight cutout
            Positioned.fill(
              child: CustomPaint(
                painter: _SpotlightPainter(
                  targetRect: targetRect,
                  overlayColor: Colors.black.withValues(alpha: 0.72),
                ),
              ),
            ),

            // Tap barrier
            Positioned.fill(
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.translucent,
              ),
            ),

            // Pulsing ring around spotlight target
            if (targetRect != null)
              Positioned(
                left: targetRect.left - 8,
                top: targetRect.top - 8,
                child: _PulsingRing(
                  width: targetRect.width + 16,
                  height: targetRect.height + 16,
                  borderRadius: _isCircularTarget(targetRect) ? 100 : 16,
                  color: step.accentColor ?? const Color(0xFF2ECC71),
                ),
              ),

            // Tooltip card
            _buildTooltip(
              step: step,
              targetRect: targetRect,
              screenSize: screenSize,
              isLastStep: isLastStep,
            ),
          ],
        ),
      ),
    );
  }

  bool _isCircularTarget(Rect rect) => (rect.width - rect.height).abs() < 20;

  Widget _buildTooltip({
    required _TutorialStep step,
    required Rect? targetRect,
    required Size screenSize,
    required bool isLastStep,
  }) {
    double? top;
    double? bottom;

    if (targetRect == null) {
      top = screenSize.height * 0.3;
    } else {
      final spaceBelow = screenSize.height - targetRect.bottom;
      if (spaceBelow > 280) {
        top = targetRect.bottom + 20;
      } else {
        bottom = screenSize.height - targetRect.top + 20;
      }
    }

    return Positioned(
      left: 24,
      right: 24,
      top: top,
      bottom: bottom,
      child: _AnimatedCard(
        stepIndex: _currentStep,
        accentColor: step.accentColor ?? const Color(0xFF2ECC71),
        child: _buildCardContent(step, isLastStep, compact: false),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Full-screen info-card step
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildInfoCardStep(_TutorialStep step, bool isLastStep) {
    final accent = step.accentColor ?? const Color(0xFF2ECC71);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.black.withValues(alpha: 0.80),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _AnimatedCard(
                stepIndex: _currentStep,
                accentColor: accent,
                child: _buildCardContent(step, isLastStep, compact: false),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared card content
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCardContent(
    _TutorialStep step,
    bool isLastStep, {
    required bool compact,
  }) {
    final accent = step.accentColor ?? const Color(0xFF2ECC71);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon badge
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent, accent.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.3),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(step.icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          step.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 10),

        // Description
        Text(
          step.description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.55,
            decoration: TextDecoration.none,
          ),
        ),

        // Optional tip pill
        if (step.tipText != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  step.tipIcon ?? Icons.lightbulb_outline,
                  size: 18,
                  color: accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step.tipText!,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: accent.withValues(alpha: 0.9),
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Step indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_steps.length, (i) {
            final isActive = i == _currentStep;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive ? accent : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        // Action buttons
        Row(
          children: [
            if (!isLastStep)
              Expanded(
                child: TextButton(
                  onPressed: _skip,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.tutorialSkip,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ),
            if (!isLastStep) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isLastStep
                      ? AppLocalizations.of(context)!.tutorialFinish
                      : AppLocalizations.of(context)!.tutorialNext,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated card wrapper with slide-up entrance per step
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedCard extends StatelessWidget {
  final int stepIndex;
  final Color accentColor;
  final Widget child;

  const _AnimatedCard({
    required this.stepIndex,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(stepIndex),
      tween: Tween(begin: 24, end: 0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOut,
      builder: (context, offset, child) =>
          Transform.translate(offset: Offset(0, offset), child: child),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.12),
              blurRadius: 32,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spotlight painter
// ─────────────────────────────────────────────────────────────────────────────
class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  final Color overlayColor;

  _SpotlightPainter({this.targetRect, required this.overlayColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;
    final fullScreen = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (targetRect != null) {
      final isCircle = (targetRect!.width - targetRect!.height).abs() < 20;
      const padding = 8.0;
      final paddedRect = targetRect!.inflate(padding);

      final cutout = Path();
      if (isCircle) {
        cutout.addOval(paddedRect);
      } else {
        cutout.addRRect(
          RRect.fromRectAndRadius(paddedRect, const Radius.circular(16)),
        );
      }

      final combined = Path.combine(
        PathOperation.difference,
        fullScreen,
        cutout,
      );
      canvas.drawPath(combined, paint);
    } else {
      canvas.drawPath(fullScreen, paint);
    }
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      targetRect != oldDelegate.targetRect ||
      overlayColor != oldDelegate.overlayColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulsing ring animation
// ─────────────────────────────────────────────────────────────────────────────
class _PulsingRing extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color color;

  const _PulsingRing({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.color,
  });

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnim = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Opacity(
            opacity: _opacityAnim.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(color: widget.color, width: 3),
              ),
            ),
          ),
        );
      },
    );
  }
}
