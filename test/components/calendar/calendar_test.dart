import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_diary/components/calendar/calendar.dart';

const _key = Key('calendar');

void main() {
  testWidgets('Renders a calendar with the provided info', (tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child:
            Material(child: Calendar(key: _key, focusedDay: DateTime.now()))));
    var avatarFinder = find.byKey(_key);
    expect(avatarFinder, findsOneWidget);
  });
}
