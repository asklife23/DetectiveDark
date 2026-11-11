import 'package:detective_dark/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DetectiveDarkApp builds a dark empty screen', (tester) async {
    await tester.pumpWidget(const DetectiveDarkApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.black);
  });
}
