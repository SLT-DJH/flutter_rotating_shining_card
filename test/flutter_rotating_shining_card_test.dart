import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rotating_shining_card/flutter_rotating_shining_card.dart';

void main() {
  final testCard = RotatingShiningCard(
    width: 200,
    height: 300,
    frontChild: Container(color: Colors.blue),
    backChild: Container(color: Colors.red),
  );

  testWidgets('renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: testCard)));
    expect(find.byType(RotatingShiningCard), findsOneWidget);
  });

  testWidgets('default values are correct', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: testCard)));
    final widget = tester.widget<RotatingShiningCard>(
      find.byType(RotatingShiningCard),
    );
    expect(widget.borderRadius, 8.0);
    expect(widget.shineIntensity, 0.5);
    expect(widget.shineColor, Colors.white);
  });

  testWidgets('shows frontChild initially', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RotatingShiningCard(
          width: 200,
          height: 300,
          frontChild: const Text('FRONT'),
          backChild: const Text('BACK'),
        ),
      ),
    ));
    expect(find.text('FRONT'), findsOneWidget);
    expect(find.text('BACK'), findsNothing);
  });

  testWidgets('responds to pan gesture', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: testCard)));
    final cardFinder = find.byType(RotatingShiningCard);

    // 왼쪽에서 오른쪽으로 스와이프
    await tester.drag(cardFinder, const Offset(300, 0));
    await tester.pumpAndSettle();

    expect(find.byType(RotatingShiningCard), findsOneWidget);
  });
}
