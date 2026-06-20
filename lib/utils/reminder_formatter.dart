import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simple_notepad/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ReminderFormatter {
  ReminderFormatter._();

  static String formatReminder(Timestamp? timestamp, String localeName) {
    if (timestamp == null) return '';
    return DateFormat.yMMMd(localeName).add_jm().format(timestamp.toDate());
  }

  static String formatReminderLabel(
    AppLocalizations l10n,
    Timestamp? timestamp,
    String? repeat,
  ) {
    if (timestamp == null) return '';
    final localeName = l10n.localeName;
    final time = DateFormat.jm(localeName).format(timestamp.toDate());
    switch (repeat) {
      case 'daily':
        return l10n.dailyAt(time);
      case 'weekly':
        return l10n.weeklyOn(
          DateFormat.E(localeName).format(timestamp.toDate()),
          time,
        );
      case 'monthly':
        return l10n.monthlyOnDay('${timestamp.toDate().day}', time);
      default:
        return formatReminder(timestamp, localeName);
    }
  }

  static String onceLabel(
    AppLocalizations l10n,
    DateTime date,
    TimeOfDay time,
    BuildContext context,
  ) {
    return l10n.dateAtTime(
      DateFormat.yMMMd(l10n.localeName).format(date),
      time.format(context),
    );
  }
}
