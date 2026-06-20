// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Bloc de notas seguro';

  @override
  String get searchNotes => 'Buscar notas';

  @override
  String get searchLockedNotes => 'Buscar notas bloqueadas';

  @override
  String get batchMode => 'Modo por lotes';

  @override
  String get lockedNotes => 'Notas bloqueadas';

  @override
  String get homeScreenWidget => 'Widget de inicio';

  @override
  String get ourNewApps => 'Nuestras apps';

  @override
  String get inviteFriends => 'Invitar amigos a la app';

  @override
  String get sendFeedback => 'Enviar comentarios';

  @override
  String get rateUs => 'Califícanos';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get languageChanged => 'Idioma actualizado';

  @override
  String get english => 'Inglés';

  @override
  String get hindi => 'Hindi';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Francés';

  @override
  String get indonesian => 'Indonesio';

  @override
  String get brazilianPortuguese => 'Portugués (Brasil)';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get addNotesToHomeScreen => 'Añade notas a tu pantalla de inicio';

  @override
  String get widgetTipDescription =>
      'Fija un widget para ver tus notas recientes sin abrir la app.';

  @override
  String get setUpWidget => 'Configurar widget';

  @override
  String get dismiss => 'Cerrar';

  @override
  String get title => 'Título';

  @override
  String get content => 'Contenido';

  @override
  String get addNote => 'Añadir nota';

  @override
  String get updateNote => 'Actualizar nota';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteNote => 'Eliminar nota';

  @override
  String get deleteNoteConfirm => '¿Seguro que quieres eliminar esta nota?';

  @override
  String get delete => 'Eliminar';

  @override
  String get noteAdded => 'Nota añadida';

  @override
  String get noteUpdated => 'Nota actualizada';

  @override
  String get noNotesYet => 'Aún no hay notas.';

  @override
  String get noNotesMatchSearch => 'Ninguna nota coincide con tu búsqueda.';

  @override
  String reminderLabel(String label) {
    return 'Recordatorio: $label';
  }

  @override
  String get couldNotLaunchEmail => 'No se pudo abrir el cliente de correo';

  @override
  String get couldNotOpenPlayStore => 'No se pudo abrir Google Play Store';

  @override
  String get inviteShareSubject => 'Prueba la app Secure Notepad';

  @override
  String get inviteShareText =>
      '¡Mira esta increíble app Secure Notepad! Me ayuda a organizar y proteger mis notas.\n\nDescárgala aquí: https://play.google.com/store/apps/details?id=com.viveksingh.notepad_app&pli=1';

  @override
  String get setUpPassword => 'Configurar contraseña';

  @override
  String get setPassword => 'Establecer contraseña';

  @override
  String get selectSecurityQuestion => 'Seleccionar pregunta de seguridad';

  @override
  String get answer => 'Respuesta';

  @override
  String get save => 'Guardar';

  @override
  String get pleaseFillAllFields => 'Completa todos los campos';

  @override
  String get passwordSecuritySet =>
      'Contraseña y pregunta de seguridad configuradas';

  @override
  String get enterPassword => 'Introducir contraseña';

  @override
  String get password => 'Contraseña';

  @override
  String get submit => 'Enviar';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get error => 'Error';

  @override
  String get securityQuestionNotSet => 'Pregunta de seguridad no configurada';

  @override
  String get ok => 'OK';

  @override
  String get securityQuestion => 'Pregunta de seguridad';

  @override
  String get incorrectPassword => 'Contraseña incorrecta';

  @override
  String get incorrectAnswer => 'Respuesta incorrecta';

  @override
  String get verify => 'Verificar';

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get pleaseEnterNewPassword => 'Introduce una nueva contraseña';

  @override
  String get passwordResetSuccess => 'Contraseña restablecida correctamente';

  @override
  String get noLockedNotesYet => 'Aún no hay notas bloqueadas.';

  @override
  String get noLockedNotesMatchSearch =>
      'Ninguna nota bloqueada coincide con tu búsqueda.';

  @override
  String get securitySetup => 'Configuración de seguridad';

  @override
  String get setUpSecurityQuestion => 'Configurar pregunta de seguridad';

  @override
  String get selectSecurityQuestionPrompt =>
      'Selecciona una pregunta de seguridad:';

  @override
  String get saveSecuritySetup => 'Guardar configuración de seguridad';

  @override
  String get pleaseSelectQuestionAndAnswer =>
      'Selecciona una pregunta y proporciona una respuesta';

  @override
  String get securitySetupCompleted => 'Configuración de seguridad completada';

  @override
  String get securityQuestionDob => '¿Cuál es tu fecha de nacimiento?';

  @override
  String get securityQuestionFood => '¿Cuál es tu comida favorita?';

  @override
  String get securityQuestionPlace => '¿Cuál es tu lugar favorito?';

  @override
  String get batchNotes => 'Notas por lotes';

  @override
  String get addTask => 'Añadir tarea';

  @override
  String get editTask => 'Editar tarea';

  @override
  String get saveBatchNote => 'Guardar nota por lotes';

  @override
  String get noBatchNotesYet => 'Aún no hay notas por lotes.';

  @override
  String get noteDeleted => 'Nota eliminada';

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String errorDeletingNote(String message) {
    return 'Error al eliminar la nota: $message';
  }

  @override
  String get taskReminder => 'Recordatorio de tarea';

  @override
  String get taskReminderCleared => 'Recordatorio de tarea eliminado';

  @override
  String get taskReminderClearedSave =>
      'Recordatorio de tarea eliminado. Guarda la nota para conservar los cambios.';

  @override
  String get taskReminderSetSave =>
      'Recordatorio de tarea configurado. Guarda la nota para activarlo.';

  @override
  String taskReminderSet(String label) {
    return 'Recordatorio de tarea: $label';
  }

  @override
  String couldNotSaveTaskReminder(String message) {
    return 'No se pudo guardar el recordatorio: $message';
  }

  @override
  String get editTaskReminder => 'Editar recordatorio de tarea';

  @override
  String get setTaskReminder => 'Configurar recordatorio de tarea';

  @override
  String get setReminder => 'Configurar recordatorio';

  @override
  String get repeat => 'Repetir';

  @override
  String get once => 'Una vez';

  @override
  String get daily => 'Diario';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get date => 'Fecha';

  @override
  String get startDate => 'Fecha de inicio';

  @override
  String get time => 'Hora';

  @override
  String get clear => 'Borrar';

  @override
  String get reminderCleared => 'Recordatorio eliminado';

  @override
  String get pleaseChooseFutureDateTime => 'Elige una fecha y hora futuras';

  @override
  String get couldNotScheduleReminder =>
      'No se pudo programar el recordatorio. Permite notificaciones y alarmas en ajustes.';

  @override
  String reminderSet(String label) {
    return 'Recordatorio configurado: $label';
  }

  @override
  String get editReminder => 'Editar recordatorio';

  @override
  String get setReminderAction => 'Configurar recordatorio';

  @override
  String moreTasks(int count) {
    return '+ $count tareas más';
  }

  @override
  String get install => 'Instalar';

  @override
  String get moreAppsComingSoon => 'Más apps próximamente.\n¡Vuelve más tarde!';

  @override
  String get seeNotesOnHomeScreen => 'Ve tus notas en la pantalla de inicio';

  @override
  String get widgetDescription =>
      'El widget muestra tus 5 notas más recientes y abre la app al tocarlo. Se actualiza automáticamente al añadir o editar notas.';

  @override
  String get widgetInstalled => 'El widget está en tu pantalla de inicio';

  @override
  String get addWidgetToHomeScreen => 'Añadir widget a inicio';

  @override
  String get showHowToAddWidget => 'Mostrar cómo añadir widget';

  @override
  String get refreshWidgetNow => 'Actualizar widget ahora';

  @override
  String get howToAddManually => 'Cómo añadir manualmente';

  @override
  String get widgetStep1 => 'Ve a la pantalla de inicio de tu teléfono';

  @override
  String get widgetStep2 => 'Mantén pulsado un espacio vacío';

  @override
  String get widgetStep3 => 'Toca Widgets';

  @override
  String get widgetStep4 => 'Busca \"Secure Notepad Notes\"';

  @override
  String get widgetStep5 => 'Arrástralo a tu pantalla de inicio';

  @override
  String get widgetOldDataTip =>
      'Si el widget muestra datos antiguos, abre la app una vez o toca \"Actualizar widget ahora\" arriba.';

  @override
  String get addWidgetManually => 'Añadir widget manualmente';

  @override
  String get widgetManualDialogContent =>
      '1. Ve a la pantalla de inicio\n2. Mantén pulsado un espacio vacío\n3. Toca Widgets\n4. Busca \"Secure Notepad Notes\"\n5. Arrástralo a tu pantalla de inicio';

  @override
  String get gotIt => 'Entendido';

  @override
  String get confirmAddWidget =>
      'Confirma al añadir el widget cuando tu teléfono lo pida.';

  @override
  String get couldNotOpenWidgetPicker =>
      'No se pudo abrir el selector de widgets. Usa los pasos manuales abajo.';

  @override
  String couldNotAddWidget(String message) {
    return 'No se pudo añadir el widget: $message';
  }

  @override
  String get widgetRefreshed => 'Widget de inicio actualizado';

  @override
  String get couldNotRefreshWidgetRetry =>
      'No se pudo actualizar el widget. Abre la app e inténtalo de nuevo.';

  @override
  String couldNotRefreshWidget(String message) {
    return 'No se pudo actualizar el widget: $message';
  }

  @override
  String couldNotLoadWidgetStatus(String message) {
    return 'No se pudo cargar el estado del widget: $message';
  }

  @override
  String get voiceInput => 'Entrada de voz';

  @override
  String get stopVoiceInput => 'Detener entrada de voz';

  @override
  String get micPermissionRequired =>
      'Se necesita permiso de micrófono para la entrada de voz.';

  @override
  String get micPermissionDeniedSettings =>
      'Permiso de micrófono denegado. Actívalo en ajustes de la app.';

  @override
  String get voiceInputNotAvailable =>
      'La entrada de voz no está disponible en este dispositivo.';

  @override
  String dailyAt(String time) {
    return 'Diario a las $time';
  }

  @override
  String weeklyOn(String day, String time) {
    return 'Semanal los $day a las $time';
  }

  @override
  String monthlyOnDay(String day, String time) {
    return 'Mensual el día $day a las $time';
  }

  @override
  String dateAtTime(String date, String time) {
    return '$date a las $time';
  }
}
