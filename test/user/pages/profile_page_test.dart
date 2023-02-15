import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:my_diary/generated/l10n.dart';
import 'package:my_diary/user/components/avatar/avatar.dart';
import 'package:my_diary/user/models/user.dart';
import 'package:my_diary/user/pages/profile_page.dart';
import 'package:provider/provider.dart';

import 'sign_in_page_test.mocks.dart';

const _key = Key('page');

void main() {
  createWidget(WidgetTester tester,
      {Function? signInCallback,
      Stream<GoogleSignInAccount>? userStream = const Stream.empty()}) async {
    final signIn = MockGoogleSignIn();

    when(signIn.onCurrentUserChanged)
        .thenAnswer((realInvocation) => userStream!);

    when(signIn.disconnect()).thenAnswer((realInvocation) => Future.value());

    final user = User(googleSignIn: signIn);
    final widget = ChangeNotifierProvider(
        create: (context) => user,
        child: MaterialApp(
          localizationsDelegates: const [
            S.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Builder(builder: (context) {
            if (signInCallback != null) {
              signInCallback(user, context);
            }

            return const Scaffold(
                body: ProfilePage(
              key: _key,
              avatar: Avatar(googleAvatarWidget: Placeholder()),
            ));
          }),
        ));

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    return user;
  }

  createWidgetSignedInWithGoogle(WidgetTester tester) {
    var signInAccount = MockGoogleSignInAccount();
    when(signInAccount.id).thenReturn('id');
    when(signInAccount.displayName).thenReturn('name');
    when(signInAccount.email).thenReturn('email');

    return createWidget(tester, userStream: Stream.value(signInAccount));
  }

  group('Profile Page', () {
    testWidgets('shows anonymous info if is logged as anonymous',
        (tester) async {
      signInCallback(User user, BuildContext context) =>
          user.signInAsAnonymous(context);
      final user = await createWidget(tester, signInCallback: signInCallback);
      expect(find.byKey(_key), findsOneWidget);
      expect(find.text(user.displayName), findsOneWidget);
      expect(find.text(user.email), findsOneWidget);
      expect(find.byType(Avatar), findsOneWidget);
    });

    testWidgets('shows google account info if is logged with google',
        (tester) async {
      final user = await createWidgetSignedInWithGoogle(tester);

      expect(find.byKey(_key), findsOneWidget);
      expect(find.text(user.displayName), findsOneWidget);
      expect(find.text(user.email), findsOneWidget);
      expect(find.byType(Avatar), findsOneWidget);
    });

    testWidgets('can logout an anonymous user', (tester) async {
      signInCallback(User user, BuildContext context) =>
          user.signInAsAnonymous(context);
      final user = await createWidget(tester, signInCallback: signInCallback);
      await tester.tap(find.byKey(logoutButtonKey));
      expect(user.isLogged, false);
    });

    testWidgets('can logout a Google user', (tester) async {
      final user = await createWidgetSignedInWithGoogle(tester);

      await tester.tap(find.byKey(logoutButtonKey));
      expect(user.isLogged, false);
    });
  });
}
