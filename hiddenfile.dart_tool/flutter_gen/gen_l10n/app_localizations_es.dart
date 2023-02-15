import 'app_localizations.dart';

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get myDiary => 'Mi Diario';

  @override
  String get entry => 'Entrada';

  @override
  String get entries => 'Entradas';

  @override
  String get newEntry => 'Nueva Entrada';

  @override
  String get editEntry => 'Editar Entrada';

  @override
  String get entryRemoved => 'Entrada borrada';

  @override
  String get entrySaved => 'Entrada guardada';

  @override
  String get undo => 'Deshacer';

  @override
  String get emptyDay => 'Este día está vacío. ¡Escribe alguna cosa!';

  @override
  String get title => 'Título';

  @override
  String get date => 'Fecha';

  @override
  String get body => 'Cuerpo';

  @override
  String get emptyFieldError => 'Este campo no puede estar vacío';

  @override
  String get anonymous => 'Anónimo';

  @override
  String get signInWithGoogle => 'Identifícate con Google';

  @override
  String get signInAnonymously => 'Entra como anónimo';

  @override
  String get logout => 'Cerrar la sesión';

  @override
  String get errorOccurred => 'Ha ocurrido un error. Por favor, prueba de nuevo';
}
