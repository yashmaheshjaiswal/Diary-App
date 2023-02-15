import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_diary/generated/l10n.dart';
import 'package:my_diary/routes.dart';
import 'package:my_diary/user/models/user.dart';
import 'package:my_diary/user/pages/sign_in_page.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'sign_in_page_test.mocks.dart';

@GenerateMocks([GoogleSignIn, GoogleSignInAccount])
const _key = Key('page');
const _fakeListPageKey = Key('route');

void main() {
  createWidget(GoogleSignIn signIn, WidgetTester tester,
      {Stream<GoogleSignInAccount>? userStream = const Stream.empty()}) async {
    when(signIn.onCurrentUserChanged)
        .thenAnswer((realInvocation) => userStream!);
    when(signIn.signInSilently())
        .thenAnswer((realInvocation) => Future.value());

    final widget = ChangeNotifierProvider(
        create: (context) => User(googleSignIn: signIn),
        child: MaterialApp(
          localizationsDelegates: const [
            S.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const SignInPage(key: _key),
          routes: {
            Routes.entryList: (context) =>
                const Placeholder(key: _fakeListPageKey)
          },
        ));

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  expectThatButtonsDisappear() {
    expect(find.byKey(anonymousSignInButtonKey), findsNothing);
    expect(find.byKey(googleSignInButtonKey), findsNothing);
  }

  expectThanButtonsAppear() {
    expect(find.byKey(googleSignInButtonKey), findsOneWidget);
    expect(find.byKey(anonymousSignInButtonKey), findsOneWidget);
  }

  group('Sign In Page', () {
    testWidgets('renders sign in buttons when is not logged', (tester) async {
      final signIn = MockGoogleSignIn();
      await createWidget(signIn, tester);

      expect(find.byKey(_key), findsOneWidget);
      verify(signIn.signInSilently()).called(1);

      expectThanButtonsAppear();
    });

    testWidgets('signs in anonymously and redirects to list page',
        (tester) async {
      await createWidget(MockGoogleSignIn(), tester);

      await tester.tap(find.byKey(anonymousSignInButtonKey));
      await tester.pump();

      expectThatButtonsDisappear();

      await tester.pumpAndSettle();

      expect(find.byKey(_fakeListPageKey), findsOneWidget);
    });

    testWidgets('signs in with google and redirects to list page',
        (tester) async {
      final signIn = MockGoogleSignIn();
      final mockAccount = MockGoogleSignInAccount();
      final userSignedIn = Completer<GoogleSignInAccount>();
      Stream<GoogleSignInAccount> userStream =
          Stream.fromFuture(userSignedIn.future);
      when(signIn.signIn()).thenAnswer((realInvocation) => Future(() {
            userSignedIn.complete(Future.value(mockAccount));
            return null;
          }));

      when(mockAccount.id).thenReturn('someId');
      when(mockAccount.displayName).thenReturn('someName');

      await createWidget(signIn, tester, userStream: userStream);

      await tester.tap(find.byKey(googleSignInButtonKey));
      await tester.pump();

      expectThatButtonsDisappear();

      await tester.pumpAndSettle();

      verify(signIn.signIn()).called(1);
      expect(find.byKey(_fakeListPageKey), findsOneWidget);
    });

    testWidgets('restores the button when sign in with google fails',
        (tester) async {
      final signIn = MockGoogleSignIn();
      when(signIn.signIn()).thenAnswer((realInvocation) => Future.delayed(
          const Duration(milliseconds: 1), () => throw 'Some error'));

      await createWidget(signIn, tester);

      await tester.tap(find.byKey(googleSignInButtonKey));
      await tester.pump();

      expectThatButtonsDisappear();

      await tester.pumpAndSettle();

      verify(signIn.signIn()).called(1);
      expectThanButtonsAppear();
      expect(find.byKey(errorKey), findsOneWidget);
    });
  });
}
