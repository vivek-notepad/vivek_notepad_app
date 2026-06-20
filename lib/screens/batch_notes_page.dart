import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_notepad/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../services/reminder_service.dart';
import '../services/speech_service.dart';
import '../services/widget_service.dart';
import '../utils/reminder_dialog.dart';
import '../utils/reminder_formatter.dart';
import '../widgets/voice_input_button.dart';

class BatchNotesPage extends StatefulWidget {
  final VoidCallback resetBatchMode;
  const BatchNotesPage({super.key, required this.resetBatchMode});

  @override
  State<BatchNotesPage> createState() => _BatchNotesPageState();
}

class _BatchNotesPageState extends State<BatchNotesPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  late final CollectionReference notesCollection;
  String? editingNoteId;
  List<Map<String, dynamic>> _tasks = [];
  Map<int, TimeOfDay?> _taskTimes = {};
  Map<int, bool> _taskTimePickers = {};
  int? _editingTaskIndex;

  @override
  void initState() {
    super.initState();
    notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes');
  }

  @override
  void dispose() {
    widget.resetBatchMode();
    super.dispose();
  }

  Future<void> _addTask() async {
    if (_taskController.text.trim().isNotEmpty) {
      setState(() {
        _tasks.insert(0, {
          'text': _taskController.text.trim(),
          'isCompleted': false,
          'time': null,
          'reminderAt': null,
          'reminderRepeat': null,
        });
        _taskTimes[0] = null;
        _taskTimePickers[0] = false;
      });
      await SpeechService.instance.stopAny();
      _taskController.clear();
    }
  }

  Map<String, dynamic> _taskToFirestore(Map<String, dynamic> task) {
    return {
      'text': task['text'],
      'isCompleted': task['isCompleted'],
      'time': task['time'],
      'reminderAt': task['reminderAt'],
      'reminderRepeat': task['reminderRepeat'],
    };
  }

  Timestamp? _taskReminderAt(Map<String, dynamic> task) {
    final value = task['reminderAt'];
    if (value is Timestamp) return value;
    return null;
  }

  String? _taskReminderRepeat(Map<String, dynamic> task) {
    return task['reminderRepeat'] as String?;
  }

  Future<void> _scheduleAllTaskReminders(
    String noteId,
    String batchTitle,
    List<Map<String, dynamic>> tasks,
  ) async {
    await ReminderService.instance.cancelAllBatchTaskReminders(noteId);
    for (var i = 0; i < tasks.length; i++) {
      final reminderAt = _taskReminderAt(tasks[i]);
      if (reminderAt == null) continue;
      await ReminderService.instance.scheduleBatchTaskReminder(
        noteId: noteId,
        taskIndex: i,
        batchTitle: batchTitle,
        taskText: tasks[i]['text']?.toString() ?? '',
        scheduledAt: reminderAt.toDate(),
        repeat: _taskReminderRepeat(tasks[i]),
      );
    }
  }

  Future<void> _handleTaskReminder(BuildContext context, int taskIndex) async {
    final l10n = AppLocalizations.of(context)!;
    final task = _tasks[taskIndex];
    final result = await showReminderDialog(
      context,
      reminderAt: _taskReminderAt(task),
      reminderRepeat: _taskReminderRepeat(task),
      dialogTitle: l10n.taskReminder,
    );
    if (result == null || !context.mounted) return;

    if (result.cleared) {
      setState(() {
        _tasks[taskIndex]['reminderAt'] = null;
        _tasks[taskIndex]['reminderRepeat'] = null;
      });
    } else {
      setState(() {
        _tasks[taskIndex]['reminderAt'] =
            Timestamp.fromDate(result.scheduledAt!);
        _tasks[taskIndex]['reminderRepeat'] =
            result.repeat == 'none' ? null : result.repeat;
      });
    }

    if (editingNoteId == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.cleared
                ? l10n.taskReminderClearedSave
                : l10n.taskReminderSetSave,
          ),
        ),
      );
      return;
    }

    final title = _titleController.text.trim();
    final tasksToSave = _tasks.map(_taskToFirestore).toList();

    try {
      await notesCollection.doc(editingNoteId).update({
        'tasks': tasksToSave,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _scheduleAllTaskReminders(editingNoteId!, title, _tasks);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.couldNotSaveTaskReminder('$e')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!context.mounted) return;
    if (result.cleared) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.taskReminderCleared)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.taskReminderSet(
              ReminderFormatter.formatReminderLabel(
                l10n,
                Timestamp.fromDate(result.scheduledAt!),
                result.repeat,
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _handleSavedTaskReminder(
    BuildContext context,
    String noteId,
    String batchTitle,
    List<dynamic> tasks,
    int taskIndex,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final mutableTasks = tasks
        .map((t) => Map<String, dynamic>.from(t as Map<String, dynamic>))
        .toList();
    final task = mutableTasks[taskIndex];
    final result = await showReminderDialog(
      context,
      reminderAt: _taskReminderAt(task),
      reminderRepeat: _taskReminderRepeat(task),
      dialogTitle: l10n.taskReminder,
    );
    if (result == null || !context.mounted) return;

    if (result.cleared) {
      mutableTasks[taskIndex]['reminderAt'] = null;
      mutableTasks[taskIndex]['reminderRepeat'] = null;
    } else {
      mutableTasks[taskIndex]['reminderAt'] =
          Timestamp.fromDate(result.scheduledAt!);
      mutableTasks[taskIndex]['reminderRepeat'] =
          result.repeat == 'none' ? null : result.repeat;
    }

    try {
      await notesCollection.doc(noteId).update({
        'tasks': mutableTasks,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _scheduleAllTaskReminders(noteId, batchTitle, mutableTasks);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.couldNotSaveTaskReminder('$e')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!context.mounted) return;
    if (result.cleared) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.taskReminderCleared)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.taskReminderSet(
              ReminderFormatter.formatReminderLabel(
                l10n,
                Timestamp.fromDate(result.scheduledAt!),
                result.repeat,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _taskReminderIcon({
    required BuildContext context,
    required int taskIndex,
    required Map<String, dynamic> task,
    double size = 20,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final reminderAt = _taskReminderAt(task);
    return IconButton(
      icon: Icon(
        reminderAt != null ? Icons.alarm_on : Icons.alarm,
        size: size,
        color: reminderAt != null ? Colors.orange : Colors.indigo,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      tooltip:
          reminderAt != null ? l10n.editTaskReminder : l10n.setTaskReminder,
      onPressed: () => _handleTaskReminder(context, taskIndex),
    );
  }

  Widget _savedTaskReminderIcon({
    required BuildContext context,
    required String noteId,
    required String batchTitle,
    required List<dynamic> tasks,
    required int taskIndex,
    required Map<String, dynamic> task,
    double size = 18,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final reminderAt = _taskReminderAt(task);
    return IconButton(
      icon: Icon(
        reminderAt != null ? Icons.alarm_on : Icons.alarm,
        size: size,
        color: reminderAt != null ? Colors.orange : Colors.indigo,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      tooltip:
          reminderAt != null ? l10n.editTaskReminder : l10n.setTaskReminder,
      onPressed: () => _handleSavedTaskReminder(
        context,
        noteId,
        batchTitle,
        tasks,
        taskIndex,
      ),
    );
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _taskTimes.remove(index);
      _taskTimePickers.remove(index);
      if (_editingTaskIndex == index) {
        _editingTaskIndex = null;
      }
    });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index]['isCompleted'] = !_tasks[index]['isCompleted'];
    });
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _taskTimes[index] ?? TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        _taskTimes[index] = picked;
        _tasks[index]['time'] = {
          'hour': picked.hour,
          'minute': picked.minute
        };
        _taskTimePickers[index] = false;
      });
    }
  }

  void _startEditingTask(int index) {
    setState(() {
      _editingTaskIndex = index;
      _taskController.text = _tasks[index]['text'];
      
      // Close any open time pickers
      _taskTimePickers.forEach((key, value) {
        if (value) {
          _taskTimePickers[key] = false;
        }
      });
    });
  }

  Future<void> _updateTask(int index) async {
    final newText = _taskController.text.trim();
    if (newText.isNotEmpty) {
      setState(() {
        _tasks[index]['text'] = newText;
        _editingTaskIndex = null;
      });
      await SpeechService.instance.stopAny();
      _taskController.clear();
    }
  }

  void _saveBatchNote() async {
    final l10n = AppLocalizations.of(context)!;
    // Close any open keyboards
    FocusScope.of(context).unfocus();
    
    // Save any pending task edits
    if (_editingTaskIndex != null) {
      final newText = _taskController.text.trim();
      if (newText.isNotEmpty) {
        setState(() {
          _tasks[_editingTaskIndex!]['text'] = newText;
        });
      }
      _taskController.clear();
      _editingTaskIndex = null;
    }

    final title = _titleController.text.trim();
    final wasEditing = editingNoteId != null;

    // Allow saving with either title or tasks
    if (title.isEmpty && _tasks.isEmpty) {
      // If we're editing and both fields are empty, delete the note
      if (wasEditing) {
        await _deleteNote(editingNoteId!);
        return;
      }else{
        return;
      }
    }

    try {
      final tasksToSave = _tasks.map(_taskToFirestore).toList();

      if (wasEditing) {
        await notesCollection.doc(editingNoteId).update({
          'title': title,
          'tasks': tasksToSave,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _scheduleAllTaskReminders(editingNoteId!, title, _tasks);
      } else {
        final docRef = await notesCollection.add({
          'title': title,
          'tasks': tasksToSave,
          'isLocked': false,
          'isBatch': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _scheduleAllTaskReminders(docRef.id, title, _tasks);
      }

      await WidgetService.instance.syncFromFirestore(userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasEditing ? l10n.noteUpdated : l10n.noteAdded),
          backgroundColor: Colors.black,
        ),
      );

      await SpeechService.instance.stopAny();
      _titleController.clear();
      setState(() {
        _tasks.clear();
        _taskTimes.clear();
        _taskTimePickers.clear();
        editingNoteId = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorMessage(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteNote(String docId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ReminderService.instance.cancelReminder(docId);
      await ReminderService.instance.cancelAllBatchTaskReminders(docId);
      await notesCollection.doc(docId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noteDeleted),
          backgroundColor: Colors.black,
        ),
      );
      _cancelEditing();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorDeletingNote(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startEditingNote(String docId, String title, List<dynamic> tasks) {
    _titleController.text = title;
    setState(() {
      editingNoteId = docId;
      _tasks = tasks.map((task) {
        return {
          'text': task['text'],
          'isCompleted': task['isCompleted'],
          'time': task['time'],
          'reminderAt': task['reminderAt'],
          'reminderRepeat': task['reminderRepeat'],
        };
      }).toList();
      
      // Initialize times and picker states
      _taskTimes.clear();
      _taskTimePickers.clear();
      for (int i = 0; i < _tasks.length; i++) {
        if (_tasks[i]['time'] != null) {
          _taskTimes[i] = TimeOfDay(
            hour: _tasks[i]['time']['hour'],
            minute: _tasks[i]['time']['minute'],
          );
        }
        _taskTimePickers[i] = false;
      }
    });
  }

  Future<void> _cancelEditing() async {
    FocusScope.of(context).unfocus();
    await SpeechService.instance.stopAny();
    _titleController.clear();
    _taskController.clear();
    setState(() {
      _tasks.clear();
      _taskTimes.clear();
      _taskTimePickers.clear();
      editingNoteId = null;
      _editingTaskIndex = null;
    });
  }

  String _formatTimestamp(Timestamp? timestamp, String localeName) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat.yMMMd(localeName).add_jm().format(date);
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  void _confirmDeleteNote(String docId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNote),
        content: Text(l10n.deleteNoteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteNote(docId);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(l10n.batchNotes, style: const TextStyle(color: Colors.indigo)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Title field
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  border: const OutlineInputBorder(),
                  suffixIcon: VoiceInputButton(controller: _titleController),
                ),
              ),
              const SizedBox(height: 10),
              
              // Task management section
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Task input row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _taskController,
                            decoration: InputDecoration(
                              labelText: _editingTaskIndex != null
                                  ? l10n.editTask
                                  : l10n.addTask,
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              suffixIcon:
                                  VoiceInputButton(controller: _taskController),
                            ),
                            onSubmitted: (_) {
                              if (_editingTaskIndex != null) {
                                _updateTask(_editingTaskIndex!);
                              } else {
                                _addTask();
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _editingTaskIndex != null 
                                ? Icons.check
                                : Icons.add,
                            color: _editingTaskIndex != null 
                                ? Colors.green
                                : Colors.indigo,
                          ),
                          onPressed: () {
                            if (_editingTaskIndex != null) {
                              _updateTask(_editingTaskIndex!);
                            } else {
                              _addTask();
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    
                    // Tasks list
                    if (_tasks.isNotEmpty)
                      Column(
                        children: _tasks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final task = entry.value;
                          final time = _taskTimes[index];
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _editingTaskIndex == index 
                                    ? Colors.blue.shade50 
                                    : null,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: task['isCompleted'],
                                        onChanged: (_) => _toggleTaskCompletion(index),
                                      ),
                                      Expanded(
                                        child: _editingTaskIndex == index
                                            ? TextField(
                                                controller: _taskController,
                                                autofocus: true,
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                                onSubmitted: (_) => _updateTask(index),
                                              )
                                            : InkWell(
                                                onTap: () => _startEditingTask(index),
                                                child: Text(
                                                  task['text'],
                                                  style: TextStyle(
                                                    decoration: task['isCompleted']
                                                        ? TextDecoration.lineThrough
                                                        : TextDecoration.none,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      if (_editingTaskIndex != index) ...[
                                        if (time != null)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Text(
                                              _formatTimeOfDay(time),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.access_time, size: 20),
                                          onPressed: () {
                                            setState(() {
                                              _taskTimePickers[index] = 
                                                  !(_taskTimePickers[index] ?? false);
                                            });
                                          },
                                        ),
                                        _taskReminderIcon(
                                          context: context,
                                          taskIndex: index,
                                          task: task,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20),
                                          onPressed: () => _removeTask(index),
                                        ),
                                      ]
                                      else ...[
                                        IconButton(
                                          icon: const Icon(Icons.check, size: 20, color: Colors.green),
                                          onPressed: () => _updateTask(index),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 20, color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              _taskController.clear();
                                              _editingTaskIndex = null;
                                            });
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                  
                                  if (_taskReminderAt(task) != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 48, bottom: 4),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          l10n.reminderLabel(
                                            ReminderFormatter.formatReminderLabel(
                                              l10n,
                                              _taskReminderAt(task),
                                              _taskReminderRepeat(task),
                                            ),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Time picker
                                  if (_taskTimePickers[index] == true)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 40, bottom: 8),
                                      child: Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => _selectTime(context, index),
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              minimumSize: const Size(0, 30),
                                            ),
                                            child: Text(
                                              time != null 
                                                  ? '${l10n.time} (${_formatTimeOfDay(time)})'
                                                  : l10n.time,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          if (time != null)
                                            IconButton(
                                              icon: const Icon(Icons.clear, size: 18),
                                              onPressed: () {
                                                setState(() {
                                                  _taskTimes[index] = null;
                                                  _tasks[index]['time'] = null;
                                                  _taskTimePickers[index] = false;
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _saveBatchNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      editingNoteId == null ? l10n.saveBatchNote : l10n.updateNote,
                    ),
                  ),
                  if (editingNoteId != null) ...[
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: _cancelEditing,
                      child: Text(l10n.cancel),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              
              // Existing batch notes list
              StreamBuilder<QuerySnapshot>(
                stream: notesCollection
                    .where('isBatch', isEqualTo: true)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final notes = snapshot.data!.docs;

                  if (notes.isEmpty) {
                    return Center(
                      child: Text(l10n.noBatchNotesYet, style: const TextStyle(fontSize: 16)),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final doc = notes[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final title = data['title'] ?? '';
                      final tasks = data['tasks'] as List<dynamic>? ?? [];
                      final createdAt =
                          _formatTimestamp(data['createdAt'], l10n.localeName);
                      final noteTitle = title;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          onTap: () => _startEditingNote(doc.id, title, tasks),
                          leading: Checkbox(
                            value: tasks.isNotEmpty 
                                ? tasks.every((task) => task['isCompleted'] == true)
                                : false,
                            onChanged: tasks.isNotEmpty
                                ? (value) {
                                    // Toggle all tasks completion
                                    final newTasks = tasks.map((task) {
                                      return {
                                        'text': task['text'],
                                        'isCompleted': value ?? false,
                                        'time': task['time'],
                                        'reminderAt': task['reminderAt'],
                                        'reminderRepeat': task['reminderRepeat'],
                                      };
                                    }).toList();
                                    notesCollection.doc(doc.id).update({
                                      'tasks': newTasks,
                                    });
                                  }
                                : null,
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: tasks.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    ...tasks.take(3).toList().asMap().entries.map((entry) {
                                      final taskIndex = entry.key;
                                      final task = entry.value as Map<String, dynamic>;
                                      final time = task['time'] != null
                                          ? TimeOfDay(
                                              hour: task['time']['hour'],
                                              minute: task['time']['minute'])
                                          : null;
                                      final taskReminderAt = _taskReminderAt(task);
                                      
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                task['isCompleted'] 
                                                    ? Icons.check_circle 
                                                    : Icons.radio_button_unchecked,
                                                size: 16,
                                                color: task['isCompleted'] 
                                                    ? Colors.green 
                                                    : Colors.grey,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  task['text'],
                                                  style: TextStyle(
                                                    decoration: task['isCompleted']
                                                        ? TextDecoration.lineThrough
                                                        : TextDecoration.none,
                                                  ),
                                                ),
                                              ),
                                              if (time != null)
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8),
                                                  child: Text(
                                                    _formatTimeOfDay(time),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              _savedTaskReminderIcon(
                                                context: context,
                                                noteId: doc.id,
                                                batchTitle: noteTitle,
                                                tasks: tasks,
                                                taskIndex: taskIndex,
                                                task: task,
                                              ),
                                            ],
                                          ),
                                          if (taskReminderAt != null)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 24, bottom: 2),
                                              child: Text(
                                                l10n.reminderLabel(
                                                  ReminderFormatter.formatReminderLabel(
                                                    l10n,
                                                    taskReminderAt,
                                                    _taskReminderRepeat(task),
                                                  ),
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    }),
                                    if (tasks.length > 3)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          l10n.moreTasks(tasks.length - 3),
                                          style: const TextStyle(fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    Text(
                                      createdAt,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                )
                              : Text(
                                  createdAt,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteNote(doc.id),
                          ),
                          isThreeLine: tasks.isNotEmpty,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}