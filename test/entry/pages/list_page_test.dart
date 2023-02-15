import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:my_diary/components/calendar/calendar.dart';
import 'package:my_diary/entry/models/entry.dart';
import 'package:my_diary/entry/pages/list_page.dart';
import 'package:my_diary/entry/services/entry_repository.dart';
import 'package:my_diary/generated/l10n.dart';
import 'package:my_diary/user/models/user.dart';
import 'package:provider/provider.dart';

import '../../user/pages/sign_in_page_test.mocks.dart';
import '../services/inmemory_entry_repository.dart';

const _key = Key('page');

void main() {
  createWidget(WidgetTester tester, {EntryRepository? repository}) async {
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    if (repository == null) {
      repository = InMemoryEntryRepository();
      await repository.persist(Entry(
          'id',
          'title',
          [
            {'insert': 'test\n'}
          ],
          DateTime.now(),
          ''));
      await repository.persist(Entry(
          'id2',
          'title2',
          [
            {'insert': 'test\n'}
          ],
          DateTime.now(),
          ''));
    }

    final signIn = MockGoogleSignIn();

    when(signIn.onCurrentUserChanged)
        .thenAnswer((realInvocation) => const Stream.empty());

    final user = User(googleSignIn: signIn);
    final widget = ChangeNotifierProvider(
        create: (context) => user,
        child: MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Builder(builder: (context) {
            user.signInAsAnonymous(context);

            return Scaffold(
                body: ListPage(
              key: _key,
              entryRepository: repository,
            ));
          }),
        ));

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    return [user];
  }

  group('List page', () {
    testWidgets(
        'renders a calendar and the empty day text if there is no data in the selected day',
        (tester) async {
      await createWidget(tester, repository: InMemoryEntryRepository());

      expect(find.byKey(_key), findsOneWidget);
      expect(find.byType(Calendar), findsOneWidget);
      expect(find.byKey(emptyDayTextKey), findsOneWidget);
    });

    testWidgets(
        'renders a list of entries where there is data in the selected day',
        (tester) async {
      await createWidget(tester);

      expect(find.byKey(_key), findsOneWidget);
      expect(find.byType(Calendar), findsOneWidget);
      expect(find.byKey(emptyDayTextKey), findsNothing);
      expect(find.text('title'), findsOneWidget);
      expect(find.text('title2'), findsOneWidget);
    });

    testWidgets(
        'renders a list of entries where there is data in the selected day',
        (tester) async {
      await createWidget(tester);

      expect(find.byKey(_key), findsOneWidget);
      expect(find.byType(Calendar), findsOneWidget);
      expect(find.byKey(emptyDayTextKey), findsNothing);
      expect(find.text('title'), findsOneWidget);
      expect(find.text('title2'), findsOneWidget);
    });

    testWidgets('remove button and swipe delete entries', (tester) async {
      await createWidget(tester);

      final secondEntry = find.text('title2');
      await tester.tap(find.byKey(removeButtonKey).first);
      await tester.drag(secondEntry, Offset.fromDirection(0, 400));

      await tester.pumpAndSettle();
      expect(find.text('title'), findsNothing);
      expect(secondEntry, findsNothing);
    });

    testWidgets('undo button restores the removed entry', (tester) async {
      await createWidget(tester);

      await tester.tap(find.byKey(removeButtonKey).first);
      await tester.pump();

      await tester.tap(find.byKey(undoButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('title'), findsOneWidget);
    });

    testWidgets('edit button opens the entry page in edit mode',
        (tester) async {
      await createWidget(tester);

      await tester.tap(find.byKey(editButtonKey).first);

      await tester.pumpAndSettle();
      expect(find.text('Edit Entry'), findsOneWidget);
    });

    testWidgets('tap entry opens the entry page in view mode', (tester) async {
      await createWidget(tester);

      await tester.tap(find.text('title'));

      await tester.pumpAndSettle();
      expect(find.text('Entry'), findsOneWidget);
    });

    testWidgets('add button opens a new entry page', (tester) async {
      await createWidget(tester);

      await tester.tap(find.byKey(addButtonKey));

      await tester.pumpAndSettle();
      expect(find.text('New Entry'), findsOneWidget);
    });
  });
}
