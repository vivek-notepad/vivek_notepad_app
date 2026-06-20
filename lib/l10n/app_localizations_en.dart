// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Secure Notepad';

  @override
  String get searchNotes => 'Search notes';

  @override
  String get searchLockedNotes => 'Search locked notes';

  @override
  String get batchMode => 'Batch Mode';

  @override
  String get lockedNotes => 'Locked Notes';

  @override
  String get homeScreenWidget => 'Home Screen Widget';

  @override
  String get ourNewApps => 'Our New Apps';

  @override
  String get inviteFriends => 'Invite friends to the app';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get rateUs => 'Rate us';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageChanged => 'Language updated';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String get spanish => 'Spanish';

  @override
  String get french => 'French';

  @override
  String get indonesian => 'Indonesian';

  @override
  String get brazilianPortuguese => 'Portuguese (Brazil)';

  @override
  String get systemDefault => 'System default';

  @override
  String get addNotesToHomeScreen => 'Add notes to your home screen';

  @override
  String get widgetTipDescription =>
      'Pin a widget to see your recent notes without opening the app.';

  @override
  String get setUpWidget => 'Set up widget';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get title => 'Title';

  @override
  String get content => 'Content';

  @override
  String get addNote => 'Add Note';

  @override
  String get updateNote => 'Update Note';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String get deleteNoteConfirm => 'Are you sure you want to delete this note?';

  @override
  String get delete => 'Delete';

  @override
  String get noteAdded => 'Note added';

  @override
  String get noteUpdated => 'Note updated';

  @override
  String get noNotesYet => 'No notes yet.';

  @override
  String get noNotesMatchSearch => 'No notes match your search.';

  @override
  String reminderLabel(String label) {
    return 'Reminder: $label';
  }

  @override
  String get couldNotLaunchEmail => 'Could not launch email client';

  @override
  String get couldNotOpenPlayStore => 'Could not open Google Play Store';

  @override
  String get inviteShareSubject => 'Try Secure Notepad App';

  @override
  String get inviteShareText =>
      'Check out this awesome Secure Notepad app! It helps me stay organized and secure my notes.\n\nDownload it here: https://play.google.com/store/apps/details?id=com.viveksingh.notepad_app&pli=1';

  @override
  String get setUpPassword => 'Set Up Password';

  @override
  String get setPassword => 'Set Password';

  @override
  String get selectSecurityQuestion => 'Select security question';

  @override
  String get answer => 'Answer';

  @override
  String get save => 'Save';

  @override
  String get pleaseFillAllFields => 'Please fill all fields';

  @override
  String get passwordSecuritySet => 'Password and security question set';

  @override
  String get enterPassword => 'Enter Password';

  @override
  String get password => 'Password';

  @override
  String get submit => 'Submit';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get error => 'Error';

  @override
  String get securityQuestionNotSet => 'Security question not set';

  @override
  String get ok => 'OK';

  @override
  String get securityQuestion => 'Security Question';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get incorrectAnswer => 'Incorrect answer';

  @override
  String get verify => 'Verify';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get pleaseEnterNewPassword => 'Please enter a new password';

  @override
  String get passwordResetSuccess => 'Password reset successfully';

  @override
  String get noLockedNotesYet => 'No locked notes yet.';

  @override
  String get noLockedNotesMatchSearch => 'No locked notes match your search.';

  @override
  String get securitySetup => 'Security Setup';

  @override
  String get setUpSecurityQuestion => 'Set up security question';

  @override
  String get selectSecurityQuestionPrompt => 'Select a security question:';

  @override
  String get saveSecuritySetup => 'Save Security Setup';

  @override
  String get pleaseSelectQuestionAndAnswer =>
      'Please select a question and provide an answer';

  @override
  String get securitySetupCompleted => 'Security setup completed successfully';

  @override
  String get securityQuestionDob => 'What is your date of birth?';

  @override
  String get securityQuestionFood => 'What is your favorite food?';

  @override
  String get securityQuestionPlace => 'Which is your favorite place?';

  @override
  String get batchNotes => 'Batch Notes';

  @override
  String get addTask => 'Add a task';

  @override
  String get editTask => 'Edit task';

  @override
  String get saveBatchNote => 'Save Batch Note';

  @override
  String get noBatchNotesYet => 'No batch notes yet.';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String errorDeletingNote(String message) {
    return 'Error deleting note: $message';
  }

  @override
  String get taskReminder => 'Task Reminder';

  @override
  String get taskReminderCleared => 'Task reminder cleared';

  @override
  String get taskReminderClearedSave =>
      'Task reminder cleared. Save note to keep changes.';

  @override
  String get taskReminderSetSave =>
      'Task reminder set. Save note to activate it.';

  @override
  String taskReminderSet(String label) {
    return 'Task reminder set: $label';
  }

  @override
  String couldNotSaveTaskReminder(String message) {
    return 'Could not save task reminder: $message';
  }

  @override
  String get editTaskReminder => 'Edit task reminder';

  @override
  String get setTaskReminder => 'Set task reminder';

  @override
  String get setReminder => 'Set Reminder';

  @override
  String get repeat => 'Repeat';

  @override
  String get once => 'Once';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get date => 'Date';

  @override
  String get startDate => 'Start date';

  @override
  String get time => 'Time';

  @override
  String get clear => 'Clear';

  @override
  String get reminderCleared => 'Reminder cleared';

  @override
  String get pleaseChooseFutureDateTime =>
      'Please choose a future date and time';

  @override
  String get couldNotScheduleReminder =>
      'Could not schedule reminder. Allow notifications and alarms in phone settings.';

  @override
  String reminderSet(String label) {
    return 'Reminder set: $label';
  }

  @override
  String get editReminder => 'Edit reminder';

  @override
  String get setReminderAction => 'Set reminder';

  @override
  String moreTasks(int count) {
    return '+ $count more tasks';
  }

  @override
  String get install => 'Install';

  @override
  String get moreAppsComingSoon => 'More apps coming soon.\nCheck back later!';

  @override
  String get seeNotesOnHomeScreen => 'See your notes on your home screen';

  @override
  String get widgetDescription =>
      'The widget shows your 5 most recent notes and opens the app when you tap it. It updates automatically when you add or edit notes.';

  @override
  String get widgetInstalled => 'Widget is on your home screen';

  @override
  String get addWidgetToHomeScreen => 'Add Widget to Home Screen';

  @override
  String get showHowToAddWidget => 'Show How to Add Widget';

  @override
  String get refreshWidgetNow => 'Refresh Widget Now';

  @override
  String get howToAddManually => 'How to add manually';

  @override
  String get widgetStep1 => 'Go to your phone home screen';

  @override
  String get widgetStep2 => 'Long-press on empty space';

  @override
  String get widgetStep3 => 'Tap Widgets';

  @override
  String get widgetStep4 => 'Find \"Secure Notepad Notes\"';

  @override
  String get widgetStep5 => 'Drag it to your home screen';

  @override
  String get widgetOldDataTip =>
      'If the widget shows old data, open the app once or tap \"Refresh Widget Now\" above.';

  @override
  String get addWidgetManually => 'Add widget manually';

  @override
  String get widgetManualDialogContent =>
      '1. Go to your phone home screen\n2. Long-press on empty space\n3. Tap Widgets\n4. Find \"Secure Notepad Notes\"\n5. Drag it to your home screen';

  @override
  String get gotIt => 'Got it';

  @override
  String get confirmAddWidget =>
      'Confirm adding the widget when your phone asks.';

  @override
  String get couldNotOpenWidgetPicker =>
      'Could not open widget picker. Use manual steps below.';

  @override
  String couldNotAddWidget(String message) {
    return 'Could not add widget: $message';
  }

  @override
  String get widgetRefreshed => 'Home screen widget refreshed';

  @override
  String get couldNotRefreshWidgetRetry =>
      'Could not refresh widget. Open the app and try again.';

  @override
  String couldNotRefreshWidget(String message) {
    return 'Could not refresh widget: $message';
  }

  @override
  String couldNotLoadWidgetStatus(String message) {
    return 'Could not load widget status: $message';
  }

  @override
  String get voiceInput => 'Voice input';

  @override
  String get stopVoiceInput => 'Stop voice input';

  @override
  String get micPermissionRequired =>
      'Microphone permission is required for voice input.';

  @override
  String get micPermissionDeniedSettings =>
      'Microphone permission denied. Enable it in app settings.';

  @override
  String get voiceInputNotAvailable =>
      'Voice input is not available on this device.';

  @override
  String voiceDailyLimitReached(int limit) {
    return 'Daily voice input limit of $limit words reached. Try again tomorrow.';
  }

  @override
  String dailyAt(String time) {
    return 'Daily at $time';
  }

  @override
  String weeklyOn(String day, String time) {
    return 'Weekly on $day at $time';
  }

  @override
  String monthlyOnDay(String day, String time) {
    return 'Monthly on day $day at $time';
  }

  @override
  String dateAtTime(String date, String time) {
    return '$date at $time';
  }
}
