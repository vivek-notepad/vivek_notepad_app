import 'package:simple_notepad/l10n/app_localizations.dart';

class SecurityQuestions {
  SecurityQuestions._();

  static const keys = ['dob', 'food', 'place'];

  static const legacyEnglish = {
    'dob': 'What is your date of birth?',
    'food': 'What is your favorite food?',
    'place': 'Which is your favorite place?',
  };

  static String label(AppLocalizations l10n, String key) {
    switch (key) {
      case 'dob':
        return l10n.securityQuestionDob;
      case 'food':
        return l10n.securityQuestionFood;
      case 'place':
        return l10n.securityQuestionPlace;
      default:
        return key;
    }
  }

  static String? keyFromStored(String? stored) {
    if (stored == null) return null;
    for (final entry in legacyEnglish.entries) {
      if (entry.value == stored) return entry.key;
    }
    if (keys.contains(stored)) return stored;
    return null;
  }

  static String displayLabel(AppLocalizations l10n, String? stored) {
    final key = keyFromStored(stored);
    if (key != null) return label(l10n, key);
    return stored ?? '';
  }
}
