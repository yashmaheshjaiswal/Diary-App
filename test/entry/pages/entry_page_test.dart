import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:my_diary/components/text_editor/text_editor.dart';
import 'package:my_diary/entry/models/entry.dart';
import 'package:my_diary/entry/pages/entry_page.dart';
import 'package:my_diary/generated/l10n.dart';
import 'package:my_diary/user/models/user.dart';
import 'package:provider/provider.dart';

import '../../user/pages/sign_in_page_test.mocks.dart';
import '../services/inmemory_entry_repository.dart';

const _key = Key('page');

void main() {
  createEntry() => Entry(
      null,
      'title',
      [
        {'insert': 'test\n'}
      ],
      DateTime(2020),
      '');

  createWidget(WidgetTester tester, {readOnly = false, Entry? entry}) async {
    final repository = InMemoryEntryRepository();
    if (entry != null) {
      await repository.persist(entry);
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
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Builder(builder: (context) {
            user.signInAsAnonymous(context);

            return Scaffold(
                body: EntryPage(
              key: _key,
              entryRepository: repository,
              entry: entry,
              day: entry == null ? DateTime(2020) : null,
              readOnly: readOnly,
            ));
          }),
        ));

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    return repository;
  }

  group('Entry Page', () {
    group('Show view', () {
      testWidgets('shows the entry fields', (tester) async {
        final entry = createEntry();
        await createWidget(tester, readOnly: true, entry: entry);

        expect(find.text(entry.title), findsOneWidget);
        expect(
            find.text(
              DateFormat.yMMMd().format(DateTime(2020)),
            ),
            findsOneWidget);
        expect(find.text('test', findRichText: true), findsOneWidget);
      });

      testWidgets('edit button changes the view to edit mode', (tester) async {
        await createWidget(tester, readOnly: true, entry: createEntry());

        await tester.tap(find.byKey(editEntryButtonKey));
        await tester.pumpAndSettle();

        expect(find.byKey(editEntryButtonKey), findsNothing);
        expect(find.byKey(saveEntryButtonKey), findsOneWidget);
      });
    });

    group('Edit view', () {
      testWidgets('validates fields', (tester) async {
        await createWidget(tester);

        expect(find.textContaining('empty'), findsNothing);

        await tester.tap(find.byKey(saveEntryButtonKey));

        await tester.pumpAndSettle();

        expect(find.textContaining('empty'), findsOneWidget);
      });

      testWidgets('creates a new entry', (tester) async {
        final repository = await createWidget(tester);

        await tester.enterText(find.byKey(titleFieldKey), 'entry title');
        final editor =
            tester.element(find.byKey(bodyFieldKey)).widget as TextEditor;
        editor.controller.compose(
            Delta.fromJson([
              {'insert': 'simulating body\n'}
            ]),
            TextSelection.fromPosition(const TextPosition(offset: 0)),
            ChangeSource.LOCAL);

        await tester.tap(find.byKey(saveEntryButtonKey));

        await tester.pumpAndSettle();
        final entry = (await repository.findByDay('', DateTime(2020)))[0];

        expect(entry.title, 'entry title');
        expect(entry.body.toString(), contains('simulating body'));
      });

      testWidgets('edits an existing entry', (tester) async {
        var entry = createEntry();
        final entryId = entry.id;

        final repository = await createWidget(tester, entry: entry);

        await tester.enterText(find.byKey(titleFieldKey), 'entry title');
        final editor =
            tester.element(find.byKey(bodyFieldKey)).widget as TextEditor;
        editor.controller.compose(
            Delta.fromJson([
              {'insert': 'simulating body\n'}
            ]),
            TextSelection.fromPosition(const TextPosition(offset: 0)),
            ChangeSource.LOCAL);

        await tester.tap(find.byKey(saveEntryButtonKey));

        await tester.pumpAndSettle();
        entry = (await repository.findByDay('', DateTime(2020)))[0];

        expect(entry.id, entryId);
        expect(entry.title, 'entry title');
        expect(entry.body.toString(), contains('simulating body'));
      });
    });
  });
}
