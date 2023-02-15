import 'app_localizations.dart';

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get myDiary => 'El meu Diari';

  @override
  String get entry => 'Entrada';

  @override
  String get entries => 'Entrades';

  @override
  String get newEntry => 'Nova Entrada';

  @override
  String get editEntry => 'Editar Entrada';

  @override
  String get entryRemoved => 'Entrada esborrada';

  @override
  String get entrySaved => 'Entrada desada';

  @override
  String get undo => 'Desfés';

  @override
  String get emptyDay => 'Aquest dia està buit. Escriu alguna cosa!';

  @override
  String get title => 'Títol';

  @override
  String get date => 'Data';

  @override
  String get body => 'Cos';

  @override
  String get emptyFieldError => 'Aquest camp no pot estar buit';

  @override
  String get anonymous => 'Anònim';

  @override
  String get signInWithGoogle => 'Identifica\'t amb Google';

  @override
  String get signInAnonymously => 'Entra com anònim';

  @override
  String get logout => 'Tanca la sessió';

  @override
  String get errorOccurred => 'Ha ocurregut un error. Sisplau, prova de nou';
}
