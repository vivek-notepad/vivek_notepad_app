import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/note_reminder_button.dart';

class ReminderDialogResult {
  final bool cleared;
  final DateTime? scheduledAt;
  final String repeat;

  const ReminderDialogResult({
    required this.cleared,
    this.scheduledAt,
    this.repeat = 'none',
  });
}

Future<ReminderDialogResult?> showReminderDialog(
  BuildContext context, {
  Timestamp? reminderAt,
  String? reminderRepeat,
  String dialogTitle = 'Set Reminder',
}) async {
  DateTime selectedDate = reminderAt?.toDate() ?? DateTime.now();
  TimeOfDay selectedTime = reminderAt != null
      ? TimeOfDay.fromDateTime(reminderAt.toDate())
      : TimeOfDay.now();
  String selectedRepeat = reminderRepeat ?? 'none';

  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final reminderLabel = selectedRepeat == 'none'
              ? '${DateFormat.yMMMd().format(selectedDate)} at ${selectedTime.format(context)}'
              : NoteReminderButton.formatReminderLabel(
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
            title: Text(dialogTitle),
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
                    decoration: const InputDecoration(
                      labelText: 'Repeat',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'none', child: Text('Once')),
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
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
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setDialogState(() => selectedDate = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            selectedRepeat == 'none' ? 'Date' : 'Start date',
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
                          label: const Text('Time'),
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

  if (result == null) return null;
  if (result == 'clear') {
    return const ReminderDialogResult(cleared: true);
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
        const SnackBar(content: Text('Please choose a future date and time')),
      );
    }
    return null;
  }

  return ReminderDialogResult(
    cleared: false,
    scheduledAt: scheduledAt,
    repeat: selectedRepeat,
  );
}
