import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simple_notepad/l10n/app_localizations.dart';
import '../services/reminder_service.dart';
import '../utils/reminder_formatter.dart';

class NoteReminderButton extends StatelessWidget {
  final CollectionReference notesCollection;
  final String noteId;
  final String noteTitle;
  final String noteContent;
  final Timestamp? reminderAt;
  final String? reminderRepeat;

  const NoteReminderButton({
    super.key,
    required this.notesCollection,
    required this.noteId,
    required this.noteTitle,
    required this.noteContent,
    this.reminderAt,
    this.reminderRepeat,
  });

  static String formatReminderLabel(
    AppLocalizations l10n,
    Timestamp? timestamp,
    String? repeat,
  ) {
    return ReminderFormatter.formatReminderLabel(l10n, timestamp, repeat);
  }

  Future<void> _showReminderDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    DateTime selectedDate = reminderAt?.toDate() ?? DateTime.now();
    TimeOfDay selectedTime = reminderAt != null
        ? TimeOfDay.fromDateTime(reminderAt!.toDate())
        : TimeOfDay.now();
    String selectedRepeat = reminderRepeat ?? 'none';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final reminderLabel = selectedRepeat == 'none'
                ? ReminderFormatter.onceLabel(
                    l10n,
                    selectedDate,
                    selectedTime,
                    context,
                  )
                : formatReminderLabel(
                    l10n,
                    Timestamp.fromDate(DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    )),
                    selectedRepeat,
                  );

            return AlertDialog(
              title: Text(l10n.setReminder),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminderLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRepeat,
                      decoration: InputDecoration(
                        labelText: l10n.repeat,
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: 'none', child: Text(l10n.once)),
                        DropdownMenuItem(value: 'daily', child: Text(l10n.daily)),
                        DropdownMenuItem(value: 'weekly', child: Text(l10n.weekly)),
                        DropdownMenuItem(value: 'monthly', child: Text(l10n.monthly)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedRepeat = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setDialogState(() => selectedDate = picked);
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              selectedRepeat == 'none'
                                  ? l10n.date
                                  : l10n.startDate,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setDialogState(() => selectedTime = picked);
                              }
                            },
                            icon: const Icon(Icons.access_time, size: 18),
                            label: Text(l10n.time),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                if (reminderAt != null)
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, 'clear'),
                    child: Text(
                      l10n.clear,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'set'),
                  child: Text(l10n.setReminder),
                ),
              ],
            );
          },
        );
      },
    );

    if (!context.mounted || result == null) return;

    if (result == 'clear') {
      await ReminderService.instance.cancelReminder(noteId);
      await notesCollection.doc(noteId).update({
        'reminderAt': null,
        'reminderRepeat': null,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.reminderCleared)),
        );
      }
      return;
    }

    final scheduledAt = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (selectedRepeat == 'none' && !scheduledAt.isAfter(DateTime.now())) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pleaseChooseFutureDateTime)),
        );
      }
      return;
    }

    await ReminderService.instance.ensurePermissions();

    final scheduled = await ReminderService.instance.scheduleReminder(
      noteId: noteId,
      title: noteTitle,
      body: noteContent,
      scheduledAt: scheduledAt,
      repeat: selectedRepeat,
    );

    if (!scheduled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotScheduleReminder)),
        );
      }
      return;
    }

    await notesCollection.doc(noteId).update({
      'reminderAt': Timestamp.fromDate(scheduledAt),
      'reminderRepeat': selectedRepeat == 'none' ? null : selectedRepeat,
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reminderSet(
            formatReminderLabel(
              l10n,
              Timestamp.fromDate(scheduledAt),
              selectedRepeat,
            ),
          )),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasReminder = reminderAt != null;

    return IconButton(
      icon: Icon(
        hasReminder ? Icons.alarm_on : Icons.alarm,
        color: hasReminder ? Colors.orange : Colors.indigo,
      ),
      tooltip: hasReminder ? l10n.editReminder : l10n.setReminderAction,
      onPressed: () => _showReminderDialog(context),
    );
  }
}
