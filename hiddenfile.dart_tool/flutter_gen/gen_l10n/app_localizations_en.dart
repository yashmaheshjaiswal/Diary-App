import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get myDiary => 'My Diary';

  @override
  String get entry => 'Entry';

  @override
  String get entries => 'Entries';

  @override
  String get newEntry => 'New Entry';

  @override
  String get editEntry => 'Edit Entry';

  @override
  String get entryRemoved => 'Entry removed';

  @override
  String get entrySaved => 'Entry saved';

  @override
  String get undo => 'Undo';

  @override
  String get emptyDay => 'This day is empty. Write something!';

  @override
  String get title => 'Title';

  @override
  String get date => 'Date';

  @override
  String get body => 'Body';

  @override
  String get emptyFieldError => 'This field can\'t be empty';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInAnonymously => 'Sign in anonymously';

  @override
  String get logout => 'Logout';

  @override
  String get errorOccurred => 'An error occurred. Please try again';
}
