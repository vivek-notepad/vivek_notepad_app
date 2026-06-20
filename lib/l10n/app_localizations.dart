import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Notepad'**
  String get appTitle;

  /// No description provided for @searchNotes.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get searchNotes;

  /// No description provided for @searchLockedNotes.
  ///
  /// In en, this message translates to:
  /// **'Search locked notes'**
  String get searchLockedNotes;

  /// No description provided for @batchMode.
  ///
  /// In en, this message translates to:
  /// **'Batch Mode'**
  String get batchMode;

  /// No description provided for @lockedNotes.
  ///
  /// In en, this message translates to:
  /// **'Locked Notes'**
  String get lockedNotes;

  /// No description provided for @homeScreenWidget.
  ///
  /// In en, this message translates to:
  /// **'Home Screen Widget'**
  String get homeScreenWidget;

  /// No description provided for @ourNewApps.
  ///
  /// In en, this message translates to:
  /// **'Our New Apps'**
  String get ourNewApps;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite friends to the app'**
  String get inviteFriends;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate us'**
  String get rateUs;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageChanged;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// No description provided for @brazilianPortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (Brazil)'**
  String get brazilianPortuguese;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @addNotesToHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Add notes to your home screen'**
  String get addNotesToHomeScreen;

  /// No description provided for @widgetTipDescription.
  ///
  /// In en, this message translates to:
  /// **'Pin a widget to see your recent notes without opening the app.'**
  String get widgetTipDescription;

  /// No description provided for @setUpWidget.
  ///
  /// In en, this message translates to:
  /// **'Set up widget'**
  String get setUpWidget;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @updateNote.
  ///
  /// In en, this message translates to:
  /// **'Update Note'**
  String get updateNote;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @deleteNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get deleteNoteConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noteAdded.
  ///
  /// In en, this message translates to:
  /// **'Note added'**
  String get noteAdded;

  /// No description provided for @noteUpdated.
  ///
  /// In en, this message translates to:
  /// **'Note updated'**
  String get noteUpdated;

  /// No description provided for @noNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.'**
  String get noNotesYet;

  /// No description provided for @noNotesMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No notes match your search.'**
  String get noNotesMatchSearch;

  /// No description provided for @reminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder: {label}'**
  String reminderLabel(String label);

  /// No description provided for @couldNotLaunchEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not launch email client'**
  String get couldNotLaunchEmail;

  /// No description provided for @couldNotOpenPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Play Store'**
  String get couldNotOpenPlayStore;

  /// No description provided for @inviteShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Try Secure Notepad App'**
  String get inviteShareSubject;

  /// No description provided for @inviteShareText.
  ///
  /// In en, this message translates to:
  /// **'Check out this awesome Secure Notepad app! It helps me stay organized and secure my notes.\n\nDownload it here: https://play.google.com/store/apps/details?id=com.viveksingh.notepad_app&pli=1'**
  String get inviteShareText;

  /// No description provided for @setUpPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Up Password'**
  String get setUpPassword;

  /// No description provided for @setPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get setPassword;

  /// No description provided for @selectSecurityQuestion.
  ///
  /// In en, this message translates to:
  /// **'Select security question'**
  String get selectSecurityQuestion;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @passwordSecuritySet.
  ///
  /// In en, this message translates to:
  /// **'Password and security question set'**
  String get passwordSecuritySet;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @securityQuestionNotSet.
  ///
  /// In en, this message translates to:
  /// **'Security question not set'**
  String get securityQuestionNotSet;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @securityQuestion.
  ///
  /// In en, this message translates to:
  /// **'Security Question'**
  String get securityQuestion;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPassword;

  /// No description provided for @incorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Incorrect answer'**
  String get incorrectAnswer;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get passwordResetSuccess;

  /// No description provided for @noLockedNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No locked notes yet.'**
  String get noLockedNotesYet;

  /// No description provided for @noLockedNotesMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No locked notes match your search.'**
  String get noLockedNotesMatchSearch;

  /// No description provided for @securitySetup.
  ///
  /// In en, this message translates to:
  /// **'Security Setup'**
  String get securitySetup;

  /// No description provided for @setUpSecurityQuestion.
  ///
  /// In en, this message translates to:
  /// **'Set up security question'**
  String get setUpSecurityQuestion;

  /// No description provided for @selectSecurityQuestionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a security question:'**
  String get selectSecurityQuestionPrompt;

  /// No description provided for @saveSecuritySetup.
  ///
  /// In en, this message translates to:
  /// **'Save Security Setup'**
  String get saveSecuritySetup;

  /// No description provided for @pleaseSelectQuestionAndAnswer.
  ///
  /// In en, this message translates to:
  /// **'Please select a question and provide an answer'**
  String get pleaseSelectQuestionAndAnswer;

  /// No description provided for @securitySetupCompleted.
  ///
  /// In en, this message translates to:
  /// **'Security setup completed successfully'**
  String get securitySetupCompleted;

  /// No description provided for @securityQuestionDob.
  ///
  /// In en, this message translates to:
  /// **'What is your date of birth?'**
  String get securityQuestionDob;

  /// No description provided for @securityQuestionFood.
  ///
  /// In en, this message translates to:
  /// **'What is your favorite food?'**
  String get securityQuestionFood;

  /// No description provided for @securityQuestionPlace.
  ///
  /// In en, this message translates to:
  /// **'Which is your favorite place?'**
  String get securityQuestionPlace;

  /// No description provided for @batchNotes.
  ///
  /// In en, this message translates to:
  /// **'Batch Notes'**
  String get batchNotes;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add a task'**
  String get addTask;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @saveBatchNote.
  ///
  /// In en, this message translates to:
  /// **'Save Batch Note'**
  String get saveBatchNote;

  /// No description provided for @noBatchNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No batch notes yet.'**
  String get noBatchNotesYet;

  /// No description provided for @noteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get noteDeleted;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(String message);

  /// No description provided for @errorDeletingNote.
  ///
  /// In en, this message translates to:
  /// **'Error deleting note: {message}'**
  String errorDeletingNote(String message);

  /// No description provided for @taskReminder.
  ///
  /// In en, this message translates to:
  /// **'Task Reminder'**
  String get taskReminder;

  /// No description provided for @taskReminderCleared.
  ///
  /// In en, this message translates to:
  /// **'Task reminder cleared'**
  String get taskReminderCleared;

  /// No description provided for @taskReminderClearedSave.
  ///
  /// In en, this message translates to:
  /// **'Task reminder cleared. Save note to keep changes.'**
  String get taskReminderClearedSave;

  /// No description provided for @taskReminderSetSave.
  ///
  /// In en, this message translates to:
  /// **'Task reminder set. Save note to activate it.'**
  String get taskReminderSetSave;

  /// No description provided for @taskReminderSet.
  ///
  /// In en, this message translates to:
  /// **'Task reminder set: {label}'**
  String taskReminderSet(String label);

  /// No description provided for @couldNotSaveTaskReminder.
  ///
  /// In en, this message translates to:
  /// **'Could not save task reminder: {message}'**
  String couldNotSaveTaskReminder(String message);

  /// No description provided for @editTaskReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit task reminder'**
  String get editTaskReminder;

  /// No description provided for @setTaskReminder.
  ///
  /// In en, this message translates to:
  /// **'Set task reminder'**
  String get setTaskReminder;

  /// No description provided for @setReminder.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get setReminder;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @once.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get once;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @reminderCleared.
  ///
  /// In en, this message translates to:
  /// **'Reminder cleared'**
  String get reminderCleared;

  /// No description provided for @pleaseChooseFutureDateTime.
  ///
  /// In en, this message translates to:
  /// **'Please choose a future date and time'**
  String get pleaseChooseFutureDateTime;

  /// No description provided for @couldNotScheduleReminder.
  ///
  /// In en, this message translates to:
  /// **'Could not schedule reminder. Allow notifications and alarms in phone settings.'**
  String get couldNotScheduleReminder;

  /// No description provided for @reminderSet.
  ///
  /// In en, this message translates to:
  /// **'Reminder set: {label}'**
  String reminderSet(String label);

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminder;

  /// No description provided for @setReminderAction.
  ///
  /// In en, this message translates to:
  /// **'Set reminder'**
  String get setReminderAction;

  /// No description provided for @moreTasks.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more tasks'**
  String moreTasks(int count);

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @moreAppsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'More apps coming soon.\nCheck back later!'**
  String get moreAppsComingSoon;

  /// No description provided for @seeNotesOnHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'See your notes on your home screen'**
  String get seeNotesOnHomeScreen;

  /// No description provided for @widgetDescription.
  ///
  /// In en, this message translates to:
  /// **'The widget shows your 5 most recent notes and opens the app when you tap it. It updates automatically when you add or edit notes.'**
  String get widgetDescription;

  /// No description provided for @widgetInstalled.
  ///
  /// In en, this message translates to:
  /// **'Widget is on your home screen'**
  String get widgetInstalled;

  /// No description provided for @addWidgetToHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Add Widget to Home Screen'**
  String get addWidgetToHomeScreen;

  /// No description provided for @showHowToAddWidget.
  ///
  /// In en, this message translates to:
  /// **'Show How to Add Widget'**
  String get showHowToAddWidget;

  /// No description provided for @refreshWidgetNow.
  ///
  /// In en, this message translates to:
  /// **'Refresh Widget Now'**
  String get refreshWidgetNow;

  /// No description provided for @howToAddManually.
  ///
  /// In en, this message translates to:
  /// **'How to add manually'**
  String get howToAddManually;

  /// No description provided for @widgetStep1.
  ///
  /// In en, this message translates to:
  /// **'Go to your phone home screen'**
  String get widgetStep1;

  /// No description provided for @widgetStep2.
  ///
  /// In en, this message translates to:
  /// **'Long-press on empty space'**
  String get widgetStep2;

  /// No description provided for @widgetStep3.
  ///
  /// In en, this message translates to:
  /// **'Tap Widgets'**
  String get widgetStep3;

  /// No description provided for @widgetStep4.
  ///
  /// In en, this message translates to:
  /// **'Find \"Secure Notepad Notes\"'**
  String get widgetStep4;

  /// No description provided for @widgetStep5.
  ///
  /// In en, this message translates to:
  /// **'Drag it to your home screen'**
  String get widgetStep5;

  /// No description provided for @widgetOldDataTip.
  ///
  /// In en, this message translates to:
  /// **'If the widget shows old data, open the app once or tap \"Refresh Widget Now\" above.'**
  String get widgetOldDataTip;

  /// No description provided for @addWidgetManually.
  ///
  /// In en, this message translates to:
  /// **'Add widget manually'**
  String get addWidgetManually;

  /// No description provided for @widgetManualDialogContent.
  ///
  /// In en, this message translates to:
  /// **'1. Go to your phone home screen\n2. Long-press on empty space\n3. Tap Widgets\n4. Find \"Secure Notepad Notes\"\n5. Drag it to your home screen'**
  String get widgetManualDialogContent;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @confirmAddWidget.
  ///
  /// In en, this message translates to:
  /// **'Confirm adding the widget when your phone asks.'**
  String get confirmAddWidget;

  /// No description provided for @couldNotOpenWidgetPicker.
  ///
  /// In en, this message translates to:
  /// **'Could not open widget picker. Use manual steps below.'**
  String get couldNotOpenWidgetPicker;

  /// No description provided for @couldNotAddWidget.
  ///
  /// In en, this message translates to:
  /// **'Could not add widget: {message}'**
  String couldNotAddWidget(String message);

  /// No description provided for @widgetRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Home screen widget refreshed'**
  String get widgetRefreshed;

  /// No description provided for @couldNotRefreshWidgetRetry.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh widget. Open the app and try again.'**
  String get couldNotRefreshWidgetRetry;

  /// No description provided for @couldNotRefreshWidget.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh widget: {message}'**
  String couldNotRefreshWidget(String message);

  /// No description provided for @couldNotLoadWidgetStatus.
  ///
  /// In en, this message translates to:
  /// **'Could not load widget status: {message}'**
  String couldNotLoadWidgetStatus(String message);

  /// No description provided for @voiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get voiceInput;

  /// No description provided for @stopVoiceInput.
  ///
  /// In en, this message translates to:
  /// **'Stop voice input'**
  String get stopVoiceInput;

  /// No description provided for @micPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required for voice input.'**
  String get micPermissionRequired;

  /// No description provided for @micPermissionDeniedSettings.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied. Enable it in app settings.'**
  String get micPermissionDeniedSettings;

  /// No description provided for @voiceInputNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Voice input is not available on this device.'**
  String get voiceInputNotAvailable;

  /// No description provided for @voiceDailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Daily voice input limit of {limit} words reached. Try again tomorrow.'**
  String voiceDailyLimitReached(int limit);

  /// No description provided for @dailyAt.
  ///
  /// In en, this message translates to:
  /// **'Daily at {time}'**
  String dailyAt(String time);

  /// No description provided for @weeklyOn.
  ///
  /// In en, this message translates to:
  /// **'Weekly on {day} at {time}'**
  String weeklyOn(String day, String time);

  /// No description provided for @monthlyOnDay.
  ///
  /// In en, this message translates to:
  /// **'Monthly on day {day} at {time}'**
  String monthlyOnDay(String day, String time);

  /// No description provided for @dateAtTime.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String dateAtTime(String date, String time);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
