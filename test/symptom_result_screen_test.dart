import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:DengueLens/l10n/app_localizations.dart';
import 'package:DengueLens/services/symptom_assessor.dart';
import 'package:DengueLens/Screens/symptom_result_screen.dart';

Widget _buildTestApp(RiskAssessment assessment) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: SymptomResultScreen(assessment: assessment),
  );
}

void main() {
  testWidgets('renders no-symptoms state with informational card', (tester) async {
    final assessment = SymptomAssessor.assess(<Symptom>{});
    await tester.pumpWidget(_buildTestApp(assessment));
    await tester.pumpAndSettle();

    expect(find.text('LOW RISK'), findsOneWidget);
    expect(find.textContaining('You reported no symptoms'), findsWidgets);
    expect(find.text('/ 14'), findsNothing); // Score ring hidden when no symptoms
  });

  testWidgets('renders normal state (moderate/high) with score ring', (tester) async {
    final assessment = SymptomAssessor.assess({
      Symptom.highFever,
      Symptom.severeHeadache,
      Symptom.skinRash,
    }); // 3 + 2 + 2 = 7 -> High
    await tester.pumpWidget(_buildTestApp(assessment));
    await tester.pumpAndSettle();

    expect(find.text('HIGH RISK'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('/ 14'), findsOneWidget);
  });

  testWidgets('renders Emergency state with alert screen and warning message', (tester) async {
    final assessment = SymptomAssessor.assess({
      Symptom.persistentVomiting,
    });
    await tester.pumpWidget(_buildTestApp(assessment));
    await tester.pumpAndSettle();

    expect(find.text('EMERGENCY'), findsOneWidget);
    expect(find.textContaining('Seek emergency medical attention'), findsOneWidget);
  });
}
