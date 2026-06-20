// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Bloc-notes sécurisé';

  @override
  String get searchNotes => 'Rechercher des notes';

  @override
  String get searchLockedNotes => 'Rechercher des notes verrouillées';

  @override
  String get batchMode => 'Mode lot';

  @override
  String get lockedNotes => 'Notes verrouillées';

  @override
  String get homeScreenWidget => 'Widget d\'accueil';

  @override
  String get ourNewApps => 'Nos nouvelles apps';

  @override
  String get inviteFriends => 'Inviter des amis';

  @override
  String get sendFeedback => 'Envoyer un avis';

  @override
  String get rateUs => 'Noter l\'app';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get languageChanged => 'Langue mise à jour';

  @override
  String get english => 'Anglais';

  @override
  String get hindi => 'Hindi';

  @override
  String get spanish => 'Espagnol';

  @override
  String get french => 'Français';

  @override
  String get indonesian => 'Indonésien';

  @override
  String get brazilianPortuguese => 'Portugais (Brésil)';

  @override
  String get systemDefault => 'Par défaut du système';

  @override
  String get addNotesToHomeScreen => 'Ajoutez des notes à l\'écran d\'accueil';

  @override
  String get widgetTipDescription =>
      'Épinglez un widget pour voir vos notes récentes sans ouvrir l\'app.';

  @override
  String get setUpWidget => 'Configurer le widget';

  @override
  String get dismiss => 'Fermer';

  @override
  String get title => 'Titre';

  @override
  String get content => 'Contenu';

  @override
  String get addNote => 'Ajouter une note';

  @override
  String get updateNote => 'Mettre à jour la note';

  @override
  String get cancel => 'Annuler';

  @override
  String get deleteNote => 'Supprimer la note';

  @override
  String get deleteNoteConfirm => 'Voulez-vous vraiment supprimer cette note ?';

  @override
  String get delete => 'Supprimer';

  @override
  String get noteAdded => 'Note ajoutée';

  @override
  String get noteUpdated => 'Note mise à jour';

  @override
  String get noNotesYet => 'Aucune note pour l\'instant.';

  @override
  String get noNotesMatchSearch =>
      'Aucune note ne correspond à votre recherche.';

  @override
  String reminderLabel(String label) {
    return 'Rappel : $label';
  }

  @override
  String get couldNotLaunchEmail => 'Impossible d\'ouvrir le client e-mail';

  @override
  String get couldNotOpenPlayStore => 'Impossible d\'ouvrir Google Play Store';

  @override
  String get inviteShareSubject => 'Essayez Secure Notepad';

  @override
  String get inviteShareText =>
      'Découvrez cette superbe app Secure Notepad ! Elle m\'aide à organiser et sécuriser mes notes.\n\nTéléchargez-la ici : https://play.google.com/store/apps/details?id=com.viveksingh.notepad_app&pli=1';

  @override
  String get setUpPassword => 'Configurer le mot de passe';

  @override
  String get setPassword => 'Définir le mot de passe';

  @override
  String get selectSecurityQuestion => 'Choisir une question de sécurité';

  @override
  String get answer => 'Réponse';

  @override
  String get save => 'Enregistrer';

  @override
  String get pleaseFillAllFields => 'Veuillez remplir tous les champs';

  @override
  String get passwordSecuritySet =>
      'Mot de passe et question de sécurité définis';

  @override
  String get enterPassword => 'Entrer le mot de passe';

  @override
  String get password => 'Mot de passe';

  @override
  String get submit => 'Envoyer';

  @override
  String get forgotPassword => 'Mot de passe oublié';

  @override
  String get error => 'Erreur';

  @override
  String get securityQuestionNotSet => 'Question de sécurité non définie';

  @override
  String get ok => 'OK';

  @override
  String get securityQuestion => 'Question de sécurité';

  @override
  String get incorrectPassword => 'Mot de passe incorrect';

  @override
  String get incorrectAnswer => 'Réponse incorrecte';

  @override
  String get verify => 'Vérifier';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get pleaseEnterNewPassword =>
      'Veuillez entrer un nouveau mot de passe';

  @override
  String get passwordResetSuccess => 'Mot de passe réinitialisé avec succès';

  @override
  String get noLockedNotesYet => 'Aucune note verrouillée pour l\'instant.';

  @override
  String get noLockedNotesMatchSearch =>
      'Aucune note verrouillée ne correspond à votre recherche.';

  @override
  String get securitySetup => 'Configuration de sécurité';

  @override
  String get setUpSecurityQuestion => 'Configurer une question de sécurité';

  @override
  String get selectSecurityQuestionPrompt =>
      'Sélectionnez une question de sécurité :';

  @override
  String get saveSecuritySetup => 'Enregistrer la configuration';

  @override
  String get pleaseSelectQuestionAndAnswer =>
      'Sélectionnez une question et fournissez une réponse';

  @override
  String get securitySetupCompleted => 'Configuration de sécurité terminée';

  @override
  String get securityQuestionDob => 'Quelle est votre date de naissance ?';

  @override
  String get securityQuestionFood => 'Quel est votre plat préféré ?';

  @override
  String get securityQuestionPlace => 'Quel est votre lieu préféré ?';

  @override
  String get batchNotes => 'Notes par lot';

  @override
  String get addTask => 'Ajouter une tâche';

  @override
  String get editTask => 'Modifier la tâche';

  @override
  String get saveBatchNote => 'Enregistrer le lot';

  @override
  String get noBatchNotesYet => 'Aucune note par lot pour l\'instant.';

  @override
  String get noteDeleted => 'Note supprimée';

  @override
  String errorMessage(String message) {
    return 'Erreur : $message';
  }

  @override
  String errorDeletingNote(String message) {
    return 'Erreur lors de la suppression : $message';
  }

  @override
  String get taskReminder => 'Rappel de tâche';

  @override
  String get taskReminderCleared => 'Rappel de tâche supprimé';

  @override
  String get taskReminderClearedSave =>
      'Rappel supprimé. Enregistrez la note pour conserver les changements.';

  @override
  String get taskReminderSetSave =>
      'Rappel défini. Enregistrez la note pour l\'activer.';

  @override
  String taskReminderSet(String label) {
    return 'Rappel de tâche : $label';
  }

  @override
  String couldNotSaveTaskReminder(String message) {
    return 'Impossible d\'enregistrer le rappel : $message';
  }

  @override
  String get editTaskReminder => 'Modifier le rappel de tâche';

  @override
  String get setTaskReminder => 'Définir un rappel de tâche';

  @override
  String get setReminder => 'Définir un rappel';

  @override
  String get repeat => 'Répéter';

  @override
  String get once => 'Une fois';

  @override
  String get daily => 'Quotidien';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get monthly => 'Mensuel';

  @override
  String get date => 'Date';

  @override
  String get startDate => 'Date de début';

  @override
  String get time => 'Heure';

  @override
  String get clear => 'Effacer';

  @override
  String get reminderCleared => 'Rappel supprimé';

  @override
  String get pleaseChooseFutureDateTime =>
      'Choisissez une date et une heure futures';

  @override
  String get couldNotScheduleReminder =>
      'Impossible de programmer le rappel. Autorisez les notifications et alarmes.';

  @override
  String reminderSet(String label) {
    return 'Rappel défini : $label';
  }

  @override
  String get editReminder => 'Modifier le rappel';

  @override
  String get setReminderAction => 'Définir un rappel';

  @override
  String moreTasks(int count) {
    return '+ $count tâches de plus';
  }

  @override
  String get install => 'Installer';

  @override
  String get moreAppsComingSoon =>
      'D\'autres apps bientôt.\nRevenez plus tard !';

  @override
  String get seeNotesOnHomeScreen => 'Voir vos notes sur l\'écran d\'accueil';

  @override
  String get widgetDescription =>
      'Le widget affiche vos 5 notes les plus récentes et ouvre l\'app au toucher. Il se met à jour automatiquement.';

  @override
  String get widgetInstalled => 'Le widget est sur votre écran d\'accueil';

  @override
  String get addWidgetToHomeScreen => 'Ajouter le widget à l\'accueil';

  @override
  String get showHowToAddWidget => 'Comment ajouter le widget';

  @override
  String get refreshWidgetNow => 'Actualiser le widget';

  @override
  String get howToAddManually => 'Ajouter manuellement';

  @override
  String get widgetStep1 => 'Allez sur l\'écran d\'accueil';

  @override
  String get widgetStep2 => 'Appuyez longuement sur un espace vide';

  @override
  String get widgetStep3 => 'Appuyez sur Widgets';

  @override
  String get widgetStep4 => 'Trouvez \"Secure Notepad Notes\"';

  @override
  String get widgetStep5 => 'Faites-le glisser sur l\'écran d\'accueil';

  @override
  String get widgetOldDataTip =>
      'Si le widget affiche d\'anciennes données, ouvrez l\'app ou appuyez sur \"Actualiser le widget\".';

  @override
  String get addWidgetManually => 'Ajouter le widget manuellement';

  @override
  String get widgetManualDialogContent =>
      '1. Allez sur l\'écran d\'accueil\n2. Appuyez longuement sur un espace vide\n3. Appuyez sur Widgets\n4. Trouvez \"Secure Notepad Notes\"\n5. Faites-le glisser sur l\'écran d\'accueil';

  @override
  String get gotIt => 'Compris';

  @override
  String get confirmAddWidget =>
      'Confirmez l\'ajout du widget lorsque votre téléphone le demande.';

  @override
  String get couldNotOpenWidgetPicker =>
      'Impossible d\'ouvrir le sélecteur de widgets. Utilisez les étapes manuelles.';

  @override
  String couldNotAddWidget(String message) {
    return 'Impossible d\'ajouter le widget : $message';
  }

  @override
  String get widgetRefreshed => 'Widget d\'accueil actualisé';

  @override
  String get couldNotRefreshWidgetRetry =>
      'Impossible d\'actualiser le widget. Ouvrez l\'app et réessayez.';

  @override
  String couldNotRefreshWidget(String message) {
    return 'Impossible d\'actualiser le widget : $message';
  }

  @override
  String couldNotLoadWidgetStatus(String message) {
    return 'Impossible de charger l\'état du widget : $message';
  }

  @override
  String get voiceInput => 'Saisie vocale';

  @override
  String get stopVoiceInput => 'Arrêter la saisie vocale';

  @override
  String get micPermissionRequired =>
      'L\'autorisation du microphone est requise pour la saisie vocale.';

  @override
  String get micPermissionDeniedSettings =>
      'Microphone refusé. Activez-le dans les paramètres de l\'app.';

  @override
  String get voiceInputNotAvailable =>
      'La saisie vocale n\'est pas disponible sur cet appareil.';

  @override
  String dailyAt(String time) {
    return 'Quotidien à $time';
  }

  @override
  String weeklyOn(String day, String time) {
    return 'Hebdomadaire le $day à $time';
  }

  @override
  String monthlyOnDay(String day, String time) {
    return 'Mensuel le jour $day à $time';
  }

  @override
  String dateAtTime(String date, String time) {
    return '$date à $time';
  }
}
