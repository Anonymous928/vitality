import 'package:afterglow/features/learn/evidence.dart';
import 'package:afterglow/features/settings/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('evidence library lists entries and opens one', (tester) async {
    await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: EvidenceLibraryScreen())));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(find.text('Draft content'), findsOneWidget);
    expect(find.text('Antihistamines'), findsOneWidget);
    expect(find.text('Specialist only'), findsWidgets);

    await tester.scrollUntilVisible(find.text('Hormonal treatments'), 200);
    await tester.tap(find.text('Hormonal treatments'));
    await tester.pumpAndSettle();
    expect(find.text('Specialist-supervised only'), findsOneWidget);
    expect(find.text('What has been reported'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('privacy policy renders headings and bold text', (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: PrivacyPolicyScreen()));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    expect(find.text('Afterglow privacy policy'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('What we collect'), 300);
    expect(find.text('What we collect'), findsOneWidget);
    // "**Nothing.**" is rendered without the asterisks.
    expect(find.textContaining('**', findRichText: true), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
