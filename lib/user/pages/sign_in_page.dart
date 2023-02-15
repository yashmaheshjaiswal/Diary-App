import 'package:flutter/material.dart';
import 'package:my_diary/generated/l10n.dart';
import 'package:my_diary/user/models/user.dart';
import 'package:provider/provider.dart';

import '../../routes.dart';

const googleSignInButtonKey = Key('google');
const anonymousSignInButtonKey = Key('anonymous');
const errorKey = Key('error');

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  bool isSigningIn = false;
  bool isErrorState = false;

  @override
  void initState() {
    super.initState();

    _signInSilentlyWithGoogle();
  }

  List<Widget> renderButtonsAndText(User user) {
    if (isSigningIn || user.isLogged) {
      return [];
    }

    final buttons = [
      _renderSignInButton(
        key: const Key('google'),
        onPressed: () => _signInWithGoogle(user),
        icon: Image.asset(
          'assets/google_icon.png',
          width: 28,
        ),
        label: S.of(context).signInWithGoogle,
      ),
      const SizedBox(height: 10),
      _renderSignInButton(
        key: const Key('anonymous'),
        onPressed: () => _signInAnonymously(user, context),
        icon: const Icon(Icons.person, color: Colors.black),
        label: S.of(context).signInAnonymously,
      )
    ];

    if (isErrorState) {
      buttons.addAll([
        const SizedBox(
          height: 50,
        ),
        Text(
            key: errorKey,
            S.of(context).errorOccurred,
            style: TextStyle(color: Theme.of(context).errorColor, fontSize: 20))
      ]);
    }

    return buttons;
  }

  Widget _renderSignInButton(
          {required Widget icon,
          required String label,
          required VoidCallback onPressed,
          Key? key}) =>
      ElevatedButton.icon(
        key: key,
        onPressed: onPressed,
        icon: icon,
        label: Text(label, style: const TextStyle(color: Colors.black)),
        style: ElevatedButton.styleFrom(
            primary: Colors.white,
            fixedSize: const Size.fromWidth(220),
            padding: const EdgeInsets.symmetric(vertical: 10)),
      );

  Future<void> _signInSilentlyWithGoogle() async {
    User user = context.read();
    setState(() {
      isSigningIn = true;
      isErrorState = false;
    });
    try {
      final signIn = await user.signInSilentlyWithGoogle();
      if (signIn == null) {
        setState(() => isSigningIn = false);
      }
    } catch (e) {
      setState(() {
        isErrorState = true;
        isSigningIn = false;
      });
    }
  }

  Future<void> _signInWithGoogle(User user) async {
    setState(() {
      isSigningIn = true;
      isErrorState = false;
    });

    try {
      final signIn = await user.signInWithGoogle();
      if (signIn == null) {
        setState(() => isSigningIn = false);
      }
    } catch (e) {
      setState(() {
        isErrorState = true;
        isSigningIn = false;
      });
    }
  }

  void _signInAnonymously(User user, BuildContext context) {
    setState(() {
      isSigningIn = true;
      isErrorState = false;
    });
    user.signInAsAnonymous(context);
  }

  Widget _buildBody() {
    final User user = context.watch<User>();

    if (user.isLogged) {
      Future.microtask(
          () => Navigator.of(context).pushReplacementNamed(Routes.entryList));
    }

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Icon(Icons.menu_book,
              size: 64, color: Theme.of(context).primaryColor),
          const SizedBox(
            height: 20,
          )
        ])),
        Expanded(
            child: Column(
          children: renderButtonsAndText(user),
        ))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }
}
