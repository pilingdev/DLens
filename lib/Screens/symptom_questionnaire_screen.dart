import 'package:DengueLens/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../services/symptom_assessor.dart';
import 'educational_library_screen.dart';
import 'symptom_result_screen.dart';

/// Symptom questionnaire screen with weighted scoring and WHO warning signs.
class SymptomQuestionnaireScreen extends StatefulWidget {
  /// The mosquitoType label from the scan result (e.g. Aedes aegypti).
  /// Pass null when opening from the bottom nav without a prior scan.
  final String? mosquitoType;
  final bool skipBittenQuestion;

  const SymptomQuestionnaireScreen({
    super.key,
    this.mosquitoType,
    this.skipBittenQuestion = false,
  });

  @override
  State<SymptomQuestionnaireScreen> createState() =>
      _SymptomQuestionnaireScreenState();
}

// ── Per-tile display metadata ─────────────────────────────────────────────────

class _SymptomTile {
  final Symptom symptom;
  final String title;
  final String subtitle;
  final IconData icon;

  const _SymptomTile({
    required this.symptom,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _SymptomQuestionnaireScreenState
    extends State<SymptomQuestionnaireScreen> {
  late bool _showChecklist;
  final Set<Symptom> _selected = {};
  bool _noSymptoms = false;

  // Warning-sign tiles (red section)
  static const List<_SymptomTile> _warningTiles = [
    _SymptomTile(
      symptom: Symptom.severeAbdominalPain,
      title: 'Severe abdominal pain',
      subtitle: 'Intense stomach pain or tenderness',
      icon: Icons.warning_amber_rounded,
    ),
    _SymptomTile(
      symptom: Symptom.persistentVomiting,
      title: 'Persistent vomiting',
      subtitle: 'Vomiting 3+ times in 24 hours',
      icon: Icons.sick,
    ),
    _SymptomTile(
      symptom: Symptom.mucosalBleeding,
      title: 'Mucosal bleeding',
      subtitle: 'Bleeding gums, nose, blood in vomit or stool',
      icon: Icons.bloodtype,
    ),
    _SymptomTile(
      symptom: Symptom.lethargyOrRestlessness,
      title: 'Lethargy or restlessness',
      subtitle: 'Extreme weakness or unusual agitation',
      icon: Icons.bedtime,
    ),
  ];

  // Regular symptom tiles
  static const List<_SymptomTile> _regularTiles = [
    _SymptomTile(
      symptom: Symptom.highFever,
      title: 'High fever',
      subtitle: 'Sudden onset above 38.5\u00b0C',
      icon: Icons.thermostat,
    ),
    _SymptomTile(
      symptom: Symptom.retroOrbitalPain,
      title: 'Eye pain',
      subtitle: 'Pain behind the eyes',
      icon: Icons.visibility,
    ),
    _SymptomTile(
      symptom: Symptom.severeJointMusclePain,
      title: 'Joint/muscle pain',
      subtitle: 'Severe \u201cbone-breaking\u201d pain',
      icon: Icons.fitness_center,
    ),
    _SymptomTile(
      symptom: Symptom.severeHeadache,
      title: 'Severe headache',
      subtitle: 'Intense pain across forehead',
      icon: Icons.psychology_alt,
    ),
    _SymptomTile(
      symptom: Symptom.skinRash,
      title: 'Skin rash',
      subtitle: 'Red spots on torso or limbs',
      icon: Icons.grain,
    ),
    _SymptomTile(
      symptom: Symptom.nausea,
      title: 'Nausea',
      subtitle: 'Mild queasiness (not persistent vomiting)',
      icon: Icons.mood_bad,
    ),
    _SymptomTile(
      symptom: Symptom.fatigue,
      title: 'Fatigue',
      subtitle: 'Extreme weakness or exhaustion',
      icon: Icons.battery_1_bar,
    ),
    _SymptomTile(
      symptom: Symptom.swollenGlands,
      title: 'Swollen glands',
      subtitle: 'Enlarged lymph nodes in neck',
      icon: Icons.account_circle,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _showChecklist = widget.skipBittenQuestion;
  }

  void _toggleSymptom(Symptom symptom) {
    setState(() {
      _noSymptoms = false;
      if (_selected.contains(symptom)) {
        _selected.remove(symptom);
      } else {
        _selected.add(symptom);
      }
    });
  }

  void _toggleNoSymptoms() {
    setState(() {
      _noSymptoms = !_noSymptoms;
      if (_noSymptoms) _selected.clear();
    });
  }

  void _submitSymptoms() {
    if (_selected.isEmpty && !_noSymptoms) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.pleaseSelectOneOption),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final vector = VectorSpecies.fromLabel(widget.mosquitoType);
    final assessment = SymptomAssessor.assess(_selected, vector: vector);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SymptomResultScreen(
          assessment: assessment,
          mosquitoType: widget.mosquitoType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.symptomCheck),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'manual_symptoms',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EducationalLibraryScreen()),
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.menu_book, color: Color(0xFF2ECC71)),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showChecklist
            ? _ChecklistView(
                warningTiles: _warningTiles,
                regularTiles: _regularTiles,
                selected: _selected,
                noSymptoms: _noSymptoms,
                onToggleNoSymptoms: _toggleNoSymptoms,
                onToggleSymptom: _toggleSymptom,
                onSubmit: _submitSymptoms,
              )
            : _BittenQuestionView(
                onYes: () => setState(() => _showChecklist = true),
                onNo: () => Navigator.of(context).pop(),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Presentational widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BittenQuestionView extends StatelessWidget {
  final VoidCallback onYes;
  final VoidCallback onNo;

  const _BittenQuestionView({required this.onYes, required this.onNo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.shade50,
              ),
              child: Icon(
                Icons.pest_control,
                size: 56,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.earlyAssessmentQuestion,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.earlyAssessmentSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onYes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        Text(AppLocalizations.of(context)!.startAssessment),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onNo,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.notNow),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistView extends StatelessWidget {
  final List<_SymptomTile> warningTiles;
  final List<_SymptomTile> regularTiles;
  final Set<Symptom> selected;
  final bool noSymptoms;
  final VoidCallback onToggleNoSymptoms;
  final void Function(Symptom) onToggleSymptom;
  final VoidCallback onSubmit;

  const _ChecklistView({
    required this.warningTiles,
    required this.regularTiles,
    required this.selected,
    required this.noSymptoms,
    required this.onToggleNoSymptoms,
    required this.onToggleSymptom,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.interactiveAssessment,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context)!.selectSymptomsPrompt,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        // Scrollable list
        Expanded(
          child: Container(
            color: const Color(0xFFF8F9FA),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                // ── Warning signs section ─────────────────────────────────
                _SectionHeader(
                  label: AppLocalizations.of(context)!.warningSigns,
                  color: const Color(0xFFE74C3C),
                  icon: Icons.emergency,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFFE74C3C).withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.warningSignsExplainer,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.red.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ...warningTiles.map((tile) => _SymptomCard(
                      tile: tile,
                      isSelected: selected.contains(tile.symptom),
                      isWarning: true,
                      onTap: () => onToggleSymptom(tile.symptom),
                    )),

                const SizedBox(height: 8),

                // ── Regular symptoms section ──────────────────────────────
                _SectionHeader(
                  label: AppLocalizations.of(context)!.regularSymptoms,
                  color: const Color(0xFF2ECC71),
                  icon: Icons.checklist,
                ),
                const SizedBox(height: 4),
                ...regularTiles.map((tile) => _SymptomCard(
                      tile: tile,
                      isSelected: selected.contains(tile.symptom),
                      isWarning: false,
                      onTap: () => onToggleSymptom(tile.symptom),
                    )),

                // ── No symptoms tile ──────────────────────────────────────
                _NoSymptomsTile(
                  isSelected: noSymptoms,
                  onTap: onToggleNoSymptoms,
                ),
              ],
            ),
          ),
        ),

        // Submit footer
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(AppLocalizations.of(context)!.submitAssessment),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _SectionHeader({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomCard extends StatelessWidget {
  final _SymptomTile tile;
  final bool isSelected;
  final bool isWarning;
  final VoidCallback onTap;

  const _SymptomCard({
    required this.tile,
    required this.isSelected,
    required this.isWarning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isWarning ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.5)
                    : Colors.grey.shade100,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 46,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : Colors.grey.shade200,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(8),
                    ),
                  ),
                ),
                Icon(tile.icon, size: 20, color: Colors.grey.shade500),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tile.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tile.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isSelected ? accentColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? accentColor
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color:
                        isSelected ? Colors.white : Colors.transparent,
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

class _NoSymptomsTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _NoSymptomsTile({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 46,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2ECC71)
                        : Colors.grey.shade200,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(8),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.noSymptomsTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.noSymptomsSubtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF2ECC71)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2ECC71)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: isSelected ? Colors.white : Colors.transparent,
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
