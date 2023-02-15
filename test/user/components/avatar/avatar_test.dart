import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_diary/generated/l10n.dart';
import 'package:my_diary/user/components/avatar/avatar.dart';
import 'package:my_diary/user/models/user.dart';
import 'package:provider/provider.dart';

const _key = Key('avatar');
const _googleKey = Key('google');

void main() {
  createWidget({logged = false}) => ChangeNotifierProvider(
      create: (context) => User(),
      child: MaterialApp(
        localizationsDelegates: const [
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(builder: (BuildContext context) {
          if (logged) {
            Future.microtask(
                () => context.read<User>().signInAsAnonymous(context));
          }
          return const Avatar(
            key: _key,
            googleAvatarWidget: Placeholder(key: _googleKey),
          );
        }),
      ));

  group('Avatar', () {
    testWidgets('renders an icon when the user is not logged', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();
      var avatarFinder = find.byIcon(Icons.person_sharp);

      expect(avatarFinder, findsOneWidget);
    });

    testWidgets('renders an icon when the user is anonymous', (tester) async {
      await tester.pumpWidget(createWidget(logged: true));
      await tester.pump();
      var avatarFinder = find.byIcon(Icons.person_sharp);

      expect(avatarFinder, findsOneWidget);
    });
  });
}
