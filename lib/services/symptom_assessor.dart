/// Dengue symptom risk assessor -- pure Dart, no Flutter dependencies.
///
/// All weights and thresholds are concentrated here so a clinical reviewer
/// can tune them without touching any UI code.
///
/// Scoring model (four layers, applied in order):
///   Layer 1 - Red-flag override: any WHO warning sign -> Emergency regardless of score.
///   Layer 2 - Weighted symptom score: each symptom contributes its weight.
///   Layer 3 - Fever gate: without high fever the result is capped at Moderate (>=7 pts).
///   Layer 4 - Mosquito exposure modifier: adds vector bonus only when >=1 symptom present.
///
/// Score bands (symptom score + vector bonus):
///   0-3  -> Low
///   4-6  -> Moderate
///   7+   -> High  (requires fever; otherwise capped at Moderate)
///   Any warning sign -> Emergency
library;

enum RiskLevel { low, moderate, high, emergency }

enum VectorSpecies {
  aegypti(2),
  albopictus(1);

  final int bonus;
  const VectorSpecies(this.bonus);

  static VectorSpecies? fromLabel(String? label) {
    final l = label?.toLowerCase() ?? '';
    if (l.contains('aegypti')) return VectorSpecies.aegypti;
    if (l.contains('albopictus')) return VectorSpecies.albopictus;
    return null;
  }
}

enum Symptom {
  // WHO warning signs
  severeAbdominalPain(0, warning: true),
  persistentVomiting(0, warning: true),
  mucosalBleeding(0, warning: true),
  lethargyOrRestlessness(0, warning: true),
  // Core dengue symptoms
  highFever(3),
  retroOrbitalPain(2),
  severeJointMusclePain(2),
  severeHeadache(2),
  skinRash(2),
  // Nonspecific
  nausea(1),
  fatigue(1),
  swollenGlands(1);

  final int weight;
  final bool warning;
  const Symptom(this.weight, {this.warning = false});
}

class RiskAssessment {
  final RiskLevel level;
  final int symptomScore;
  final int vectorBonus;
  final bool hasWarningSign;
  final bool noSymptoms;
  final List<Symptom> topContributors;

  const RiskAssessment({
    required this.level,
    required this.symptomScore,
    required this.vectorBonus,
    required this.hasWarningSign,
    required this.noSymptoms,
    required this.topContributors,
  });

  int get total => symptomScore + vectorBonus;
}

class SymptomAssessor {
  static const int moderateThreshold = 4;
  static const int highThreshold = 7;

  static RiskAssessment assess(
    Set<Symptom> selected, {
    VectorSpecies? vector,
  }) {
    final hasWarning = selected.any((s) => s.warning);
    final symptomScore = selected.fold<int>(0, (sum, s) => sum + s.weight);
    final hasFever = selected.contains(Symptom.highFever);
    final vectorBonus =
        (selected.isNotEmpty && vector != null) ? vector.bonus : 0;
    final total = symptomScore + vectorBonus;

    RiskLevel level;
    if (hasWarning) {
      level = RiskLevel.emergency;
    } else if (total >= highThreshold) {
      level = hasFever ? RiskLevel.high : RiskLevel.moderate;
    } else if (total >= moderateThreshold) {
      level = RiskLevel.moderate;
    } else {
      level = RiskLevel.low;
    }

    final contributors = selected
        .where((s) => !s.warning)
        .toList()
      ..sort((a, b) => b.weight.compareTo(a.weight));

    return RiskAssessment(
      level: level,
      symptomScore: symptomScore,
      vectorBonus: vectorBonus,
      hasWarningSign: hasWarning,
      noSymptoms: selected.isEmpty,
      topContributors: contributors.take(2).toList(),
    );
  }
}
