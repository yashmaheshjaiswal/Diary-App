import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:my_diary/entry/pages/entry_page.dart';
import 'package:my_diary/entry/pages/list_page.dart';
import 'package:my_diary/entry/services/entry_repository.dart';
import 'package:my_diary/routes.dart';
import 'package:my_diary/user/pages/sign_in_page.dart';
import 'package:my_diary/user/models/user.dart';
import 'package:provider/provider.dart';
import 'generated/l10n.dart';

void main() async {
  await Hive.initFlutter();
  EntryRepository.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => User()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'My Diary',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const SignInPage(),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      routes: {
        Routes.entryList: (context) => const ListPage(),
        Routes.entry: (context) => const EntryPage(),
      },
    );
  }
}
