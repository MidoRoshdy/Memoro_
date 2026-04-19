import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memoro/app.dart';

void main() {
  testWidgets('Splash page renders brand image', (WidgetTester tester) async {
    await tester.pumpWidget(const MemoroApp());
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsWidgets);
  });
}
