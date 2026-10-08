import 'package:flutter_test/flutter_test.dart';
import 'package:DengueLens/services/symptom_assessor.dart';

void main() {
  group('SymptomAssessor', () {
    test('no symptoms → Low risk, score 0', () {
      final result = SymptomAssessor.assess(<Symptom>{});
      expect(result.level, RiskLevel.low);
      expect(result.total, 0);
      expect(result.noSymptoms, isTrue);
    });

    test('fever alone → Low risk (weight 3, under threshold 4)', () {
      final result = SymptomAssessor.assess({Symptom.highFever});
      expect(result.level, RiskLevel.low);
      expect(result.symptomScore, 3);
    });

    test('fever + nausea → Moderate (3+1 = 4)', () {
      final result = SymptomAssessor.assess({
        Symptom.highFever,
        Symptom.nausea,
      });
      expect(result.level, RiskLevel.moderate);
      expect(result.total, 4);
    });

    test('high score without fever caps at Moderate', () {
      // retroOrbitalPain(2) + severeJointMusclePain(2) + severeHeadache(2)
      // + skinRash(2) = 8 ≥ 7 but no fever → moderate
      final result = SymptomAssessor.assess({
        Symptom.retroOrbitalPain,
        Symptom.severeJointMusclePain,
        Symptom.severeHeadache,
        Symptom.skinRash,
      });
      expect(result.level, RiskLevel.moderate);
    });

    test('high score with fever → High', () {
      // highFever(3) + retroOrbitalPain(2) + severeJointMusclePain(2) = 7
      final result = SymptomAssessor.assess({
        Symptom.highFever,
        Symptom.retroOrbitalPain,
        Symptom.severeJointMusclePain,
      });
      expect(result.level, RiskLevel.high);
      expect(result.total, greaterThanOrEqualTo(7));
    });

    test('warning sign overrides to Emergency regardless of score', () {
      final result = SymptomAssessor.assess({Symptom.persistentVomiting});
      expect(result.level, RiskLevel.emergency);
      expect(result.hasWarningSign, isTrue);
    });

    test('aegypti vector bonus adds +2', () {
      final without = SymptomAssessor.assess({Symptom.highFever});
      final with_ = SymptomAssessor.assess(
        {Symptom.highFever},
        vector: VectorSpecies.aegypti,
      );
      expect(with_.total, without.total + 2);
      expect(with_.vectorBonus, 2);
    });

    test('albopictus vector bonus adds +1', () {
      final without = SymptomAssessor.assess({Symptom.highFever});
      final with_ = SymptomAssessor.assess(
        {Symptom.highFever},
        vector: VectorSpecies.albopictus,
      );
      expect(with_.total, without.total + 1);
      expect(with_.vectorBonus, 1);
    });

    test('vector bonus is NOT applied when no symptoms selected', () {
      final result = SymptomAssessor.assess(
        <Symptom>{},
        vector: VectorSpecies.aegypti,
      );
      expect(result.vectorBonus, 0);
      expect(result.total, 0);
    });

    test('multiple warning signs all trigger Emergency', () {
      final result = SymptomAssessor.assess({
        Symptom.persistentVomiting,
        Symptom.mucosalBleeding,
        Symptom.severeAbdominalPain,
      });
      expect(result.level, RiskLevel.emergency);
      expect(result.hasWarningSign, isTrue);
    });

    test('topContributors excludes warning signs and is sorted by weight', () {
      final result = SymptomAssessor.assess({
        Symptom.highFever,
        Symptom.nausea,
        Symptom.retroOrbitalPain,
      });
      expect(result.topContributors.length, lessThanOrEqualTo(2));
      // highFever has weight 3, retroOrbitalPain has weight 2 → those should be first
      expect(result.topContributors.first, Symptom.highFever);
    });

    test('scoring bands: 0-3 low, 4-6 moderate, 7+ high', () {
      // Score exactly 3 → low (fever=3)
      final low = SymptomAssessor.assess({Symptom.highFever});
      expect(low.level, RiskLevel.low);
      expect(low.symptomScore, 3);

      // Score exactly 4 → moderate (fever=3 + nausea=1)
      final mod = SymptomAssessor.assess({Symptom.highFever, Symptom.nausea});
      expect(mod.level, RiskLevel.moderate);
      expect(mod.total, 4);

      // Score 7 with fever → high (fever=3 + retroOrbital=2 + joint=2)
      final high = SymptomAssessor.assess({
        Symptom.highFever,
        Symptom.retroOrbitalPain,
        Symptom.severeJointMusclePain,
      });
      expect(high.level, RiskLevel.high);
      expect(high.total, 7);
    });
  });

  group('VectorSpecies.fromLabel', () {
    test('parses Aedes aegypti label', () {
      expect(VectorSpecies.fromLabel('Aedes aegypti'), VectorSpecies.aegypti);
    });

    test('parses Aedes albopictus label', () {
      expect(
        VectorSpecies.fromLabel('Aedes albopictus'),
        VectorSpecies.albopictus,
      );
    });

    test('returns null for unknown label', () {
      expect(VectorSpecies.fromLabel('Culex'), isNull);
    });

    test('returns null for null label', () {
      expect(VectorSpecies.fromLabel(null), isNull);
    });
  });

  group('Table-driven specification cases', () {
    final cases = <(String, Set<Symptom>, VectorSpecies?, RiskLevel)>[
      ('no symptoms + aegypti', {}, VectorSpecies.aegypti, RiskLevel.low),
      (
        'fatigue + glands',
        {Symptom.fatigue, Symptom.swollenGlands},
        null,
        RiskLevel.low
      ),
      (
        'fever + nausea',
        {Symptom.highFever, Symptom.nausea},
        null,
        RiskLevel.moderate
      ),
      (
        'fever + eye + joint',
        {
          Symptom.highFever,
          Symptom.retroOrbitalPain,
          Symptom.severeJointMusclePain
        },
        null,
        RiskLevel.high
      ),
      (
        'no fever, 4 core symptoms',
        {
          Symptom.skinRash,
          Symptom.severeHeadache,
          Symptom.retroOrbitalPain,
          Symptom.severeJointMusclePain
        },
        null,
        RiskLevel.moderate
      ),
      (
        'warning sign overrides',
        {Symptom.persistentVomiting},
        null,
        RiskLevel.emergency
      ),
      (
        'rash + albopictus',
        {Symptom.skinRash},
        VectorSpecies.albopictus,
        RiskLevel.low
      ),
      ('boundary 3 -> low', {Symptom.highFever}, null, RiskLevel.low),
      (
        'boundary 4 -> moderate',
        {Symptom.highFever, Symptom.nausea},
        null,
        RiskLevel.moderate
      ),
    ];

    for (final c in cases) {
      test(c.$1, () {
        expect(SymptomAssessor.assess(c.$2, vector: c.$3).level, c.$4);
      });
    }
  });
}
