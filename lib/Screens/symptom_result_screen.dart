import 'package:DengueLens/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../services/symptom_assessor.dart';

/// Displays the weighted risk assessment result from [SymptomAssessor].
///
/// Three render states:
///   1. No symptoms -- calm informational card.
///   2. Normal result -- Low / Moderate / High with care tips.
///   3. Emergency -- red full-screen alert with seek care now messaging.
class SymptomResultScreen extends StatelessWidget {
  final RiskAssessment assessment;

  /// Original mosquito label string (used for display only).
  final String? mosquitoType;

  const SymptomResultScreen({
    super.key,
    required this.assessment,
    this.mosquitoType,
  });

  // ── Colours ────────────────────────────────────────────────────────────────
  static const Color _green = Color(0xFF2ECC71);
  static const Color _orange = Color(0xFFF39C12);
  static const Color _deepOrange = Color(0xFFE67E22);
  static const Color _red = Color(0xFFE74C3C);

  Color get _levelColor {
    switch (assessment.level) {
      case RiskLevel.low:
        return _green;
      case RiskLevel.moderate:
        return _orange;
      case RiskLevel.high:
        return _deepOrange;
      case RiskLevel.emergency:
        return _red;
    }
  }

  String _levelLabel(AppLocalizations loc) {
    switch (assessment.level) {
      case RiskLevel.low:
        return loc.riskLevelLow;
      case RiskLevel.moderate:
        return loc.riskLevelModerate;
      case RiskLevel.high:
        return loc.riskLevelHigh;
      case RiskLevel.emergency:
        return loc.riskLevelEmergency;
    }
  }

  String _summaryText(AppLocalizations loc) {
    if (assessment.noSymptoms) return loc.riskSummaryNoSymptoms;
    switch (assessment.level) {
      case RiskLevel.low:
        return loc.riskSummaryLow;
      case RiskLevel.moderate:
        return loc.riskSummaryModerate;
      case RiskLevel.high:
        return loc.riskSummaryHigh;
      case RiskLevel.emergency:
        return loc.riskSummaryEmergency;
    }
  }

  List<Map<String, dynamic>> _careTips(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return [
          {
            'title': 'Monitor Health',
            'subtitle': 'Watch for any new or worsening symptoms',
            'icon': Icons.visibility_outlined,
          },
          {
            'title': 'Use Protection',
            'subtitle': 'Mosquito repellent and protective clothing',
            'icon': Icons.shield_outlined,
          },
        ];
      case RiskLevel.moderate:
        return [
          {
            'title': 'Rest',
            'subtitle': 'Limit physical exertion to aid recovery',
            'icon': Icons.hotel_outlined,
          },
          {
            'title': 'Hydrate',
            'subtitle': 'Fluids and electrolytes consistently',
            'icon': Icons.local_drink_outlined,
          },
          {
            'title': 'Monitor',
            'subtitle': 'Watch for worsening or new symptoms',
            'icon': Icons.visibility_outlined,
          },
        ];
      case RiskLevel.high:
        return [
          {
            'title': 'Seek Medical Care',
            'subtitle': 'Visit a healthcare facility today',
            'icon': Icons.local_hospital_outlined,
          },
          {
            'title': 'Blood Test',
            'subtitle': 'Confirm dengue diagnosis (NS1/CBC)',
            'icon': Icons.science_outlined,
          },
          {
            'title': 'Avoid NSAIDs',
            'subtitle': 'No aspirin or ibuprofen',
            'icon': Icons.dangerous_outlined,
          },
        ];
      case RiskLevel.emergency:
        return [
          {
            'title': 'Emergency Care',
            'subtitle': 'Go to the nearest ER immediately',
            'icon': Icons.local_hospital_outlined,
          },
        ];
    }
  }

  // ── Why this result contributor line ────────────────────────────────────

  String _contributorLine(AppLocalizations loc) {
    if (assessment.hasWarningSign) return loc.whyResultWarningSigns;
    if (assessment.noSymptoms) return '';
    if (assessment.topContributors.isEmpty) return '';

    final names = assessment.topContributors.map((s) {
      switch (s) {
        case Symptom.highFever:
          return loc.symptomHighFever;
        case Symptom.retroOrbitalPain:
          return loc.symptomEyePain;
        case Symptom.severeJointMusclePain:
          return loc.symptomJointPain;
        case Symptom.severeHeadache:
          return loc.symptomSevereHeadache;
        case Symptom.skinRash:
          return loc.symptomSkinRash;
        case Symptom.nausea:
          return loc.symptomNausea;
        case Symptom.fatigue:
          return loc.symptomFatigue;
        case Symptom.swollenGlands:
          return loc.symptomSwollenGlands;
        default:
          return '';
      }
    }).where((s) => s.isNotEmpty).toList();

    if (names.isEmpty) return '';
    return loc.whyResultContributors(names.join(loc.andConnector));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // Emergency state gets its own full-screen layout
    if (assessment.level == RiskLevel.emergency) {
      return _EmergencyScreen(loc: loc);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          loc.riskAssessment,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Medical disclaimer ──────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.amber.shade800, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        loc.medicalDisclaimerText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Score ring ──────────────────────────────────────────────
              if (!assessment.noSymptoms) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: assessment.total / 14.0,
                          strokeWidth: 5,
                          strokeCap: StrokeCap.round,
                          backgroundColor:
                              _levelColor.withValues(alpha: 0.18),
                          color: _levelColor,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            loc.score,
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.2,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${assessment.total}',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: _levelColor,
                              height: 1,
                            ),
                          ),
                          Text(
                            '/ 14',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else
                const SizedBox(height: 24),

              // ── No-symptoms message ─────────────────────────────────────
              if (assessment.noSymptoms)
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: _green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: _green, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.riskSummaryNoSymptoms,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 18),

              // ── Risk badge ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: _levelColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _levelColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_levelLabel(loc).toUpperCase()} RISK',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: _levelColor,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Vector bonus note ───────────────────────────────────────
              if (assessment.vectorBonus > 0 && !assessment.noSymptoms) ...[
                const SizedBox(height: 10),
                Text(
                  loc.vectorBonusNote(mosquitoType ?? 'Dengue vector',
                      assessment.vectorBonus),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // ── Contributor line (why this result) ─────────────────────
              if (!assessment.noSymptoms) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _contributorLine(loc),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 36),

              // ── Home care tips ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            loc.homeCareProtocol,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _levelColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            loc.recommended,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: _levelColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _CareTipsGrid(
                      tips: _careTips(assessment.level),
                      accent: _levelColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Assessment summary text ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.assessmentSummary,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade500,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _summaryText(loc),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.65,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ── Back to home ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_forward, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          loc.continue_btn,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                child: Text(
                  loc.backToHome,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Emergency full-screen
// ─────────────────────────────────────────────────────────────────────────────

class _EmergencyScreen extends StatelessWidget {
  final AppLocalizations loc;
  const _EmergencyScreen({required this.loc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE74C3C),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.emergency, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              loc.riskLevelEmergency.toUpperCase(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                loc.riskSummaryEmergency,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.6,
                ),
              ),
            ),
            const Spacer(),

            // White care card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      loc.homeCareProtocol,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE74C3C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CareRow(
                        icon: Icons.local_hospital_outlined,
                        text: loc.emergencyCare1),
                    const SizedBox(height: 8),
                    _CareRow(
                        icon: Icons.warning_amber_rounded,
                        text: loc.emergencyCare2),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFE74C3C),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    loc.backToHome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Disclaimer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                loc.medicalDisclaimerText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CareRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CareRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFFE74C3C)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Care tips grid
// ─────────────────────────────────────────────────────────────────────────────

class _CareTipsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> tips;
  final Color accent;

  const _CareTipsGrid({required this.tips, required this.accent});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: tips.length == 1 ? 1 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: tips.length == 1 ? 124 : 132,
      ),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index];
        return Material(
          color: Colors.white,
          elevation: 1.5,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.14),
                  ),
                  child: Icon(tip['icon'] as IconData,
                      size: 22, color: accent),
                ),
                const SizedBox(height: 10),
                Text(
                  tip['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    tip['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
