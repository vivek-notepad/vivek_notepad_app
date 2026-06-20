import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/reminder_service.dart';

class NoteReminderButton extends StatelessWidget {
  final CollectionReference notesCollection;
  final String noteId;
  final String noteTitle;
  final String noteContent;
  final Timestamp? reminderAt;

  const NoteReminderButton({
    super.key,
    required this.notesCollection,
    required this.noteId,
    required this.noteTitle,
    required this.noteContent,
    this.reminderAt,
  });

  static String formatReminder(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat.yMMMd().add_jm().format(timestamp.toDate());
  }

  Future<void> _showReminderDialog(BuildContext context) async {
    DateTime selectedDate = reminderAt?.toDate() ?? DateTime.now();
    TimeOfDay selectedTime = reminderAt != null
        ? TimeOfDay.fromDateTime(reminderAt!.toDate())
        : TimeOfDay.now();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final reminderLabel =
                '${DateFormat.yMMMd().format(selectedDate)} at ${selectedTime.format(context)}';

            return AlertDialog(
              title: const Text('Set Reminder'),
              content: Column(
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setDialogState(() => selectedDate = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text('Date'),
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
                          label: const Text('Time'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                if (reminderAt != null)
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, 'clear'),
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'set'),
                  child: const Text('Set Reminder'),
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
      await notesCollection.doc(noteId).update({'reminderAt': null});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder cleared')),
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

    if (!scheduledAt.isAfter(DateTime.now())) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please choose a future date and time')),
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
    );

    if (!scheduled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not schedule reminder. Allow notifications and alarms in phone settings.',
            ),
          ),
        );
      }
      return;
    }

    await notesCollection.doc(noteId).update({
      'reminderAt': Timestamp.fromDate(scheduledAt),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reminder set for ${formatReminder(Timestamp.fromDate(scheduledAt))}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasReminder = reminderAt != null;

    return IconButton(
      icon: Icon(
        hasReminder ? Icons.alarm_on : Icons.alarm,
        color: hasReminder ? Colors.orange : Colors.indigo,
      ),
      tooltip: hasReminder ? 'Edit reminder' : 'Set reminder',
      onPressed: () => _showReminderDialog(context),
    );
  }
}
