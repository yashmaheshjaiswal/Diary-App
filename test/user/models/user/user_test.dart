import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_diary/generated/l10n.dart';
import 'package:my_diary/user/models/user.dart';

class _MockedGoogleIdentity implements GoogleIdentity {
  @override
  String? get displayName => 'name';

  @override
  String get email => 'email';

  @override
  String get id => 'id';

  @override
  String? get photoUrl => 'photo';

  @override
  String? get serverAuthCode => 'code';
}

void main() {
  createWidget({Function? userAction}) => MaterialApp(
        localizationsDelegates: const [
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        locale: const Locale('en'),
        home: Builder(builder: (context) {
          if (userAction != null) {
            userAction(context);
          }
          return const Placeholder();
        }),
      );

  group('User', () {
    User? user;

    setUp(() {
      user = User();
    });

    test('is not logged by default', () {
      expect(user!.id, '');
      expect(user!.displayName, '');
      expect(user!.email, '');
      expect(user!.isLogged, false);
      expect(user!.serverAuthCode, null);
    });

    testWidgets('can sign in as anonymous', (tester) async {
      await tester.pumpWidget(createWidget(
          userAction: (context) => user!.signInAsAnonymous(context)));
      await tester.pump();

      expect(user!.id, '');
      expect(user!.displayName, 'Anonymous');
      expect(user!.email, '');
      expect(user!.isLogged, true);
    });

    test('can sign in with Google (mocked values)', () {
      user!.updateFromGoogleSignIn(_MockedGoogleIdentity());
      expect(user!.isLogged, true);
      expect(user!.id, 'id');
      expect(user!.displayName, 'name');
      expect(user!.email, 'email');
      expect(user!.serverAuthCode, 'code');
    });

    test('logout clears the user info', () {
      user!.updateFromGoogleSignIn(_MockedGoogleIdentity());
      user!.signInAccount = null; // Avoids calling google lib
      user!.logout();

      expect(user!.id, '');
      expect(user!.displayName, '');
      expect(user!.email, '');
      expect(user!.isLogged, false);
      expect(user!.serverAuthCode, null);
    });
  });
}
