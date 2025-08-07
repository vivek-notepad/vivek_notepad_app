import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  void _addTask() {
    if (_taskController.text.trim().isNotEmpty) {
      setState(() {
        _tasks.insert(0, {
          'text': _taskController.text.trim(),
          'isCompleted': false,
          'time': null,
        });
        _taskTimes[0] = null;
        _taskTimePickers[0] = false;
      });
      _taskController.clear();
    }
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

  void _updateTask(int index) {
    final newText = _taskController.text.trim();
    if (newText.isNotEmpty) {
      setState(() {
        _tasks[index]['text'] = newText;
        _taskController.clear();
        _editingTaskIndex = null;
      });
    }
  }

  void _saveBatchNote() async {
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

    if (title.isEmpty) return;

    try {
      // Convert tasks to Firestore-compatible format
      final tasksToSave = _tasks.map((task) {
        return {
          'text': task['text'],
          'isCompleted': task['isCompleted'],
          'time': task['time'],
        };
      }).toList();

      if (wasEditing) {
        await notesCollection.doc(editingNoteId).update({
          'title': title,
          'tasks': tasksToSave,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await notesCollection.add({
          'title': title,
          'tasks': tasksToSave,
          'isLocked': false,
          'isBatch': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasEditing ? 'Note updated' : 'Note added'),
          backgroundColor: Colors.black,
        ),
      );

      // Clear all fields
      _titleController.clear();
      setState(() {
        _tasks.clear();
        _taskTimes.clear();
        _taskTimePickers.clear();
        editingNoteId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
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

  void _cancelEditing() {
    FocusScope.of(context).unfocus();
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

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat.yMMMd().add_jm().format(date);
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  void _confirmDeleteNote(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await notesCollection.doc(docId).delete();
              if (editingNoteId == docId) {
                _cancelEditing();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Batch Notes', style: TextStyle(color: Colors.indigo)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Title field
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
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
                            decoration: const InputDecoration(
                              labelText: 'Add a task',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            onSubmitted: (_) => _addTask(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTask,
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
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20),
                                          onPressed: () => _removeTask(index),
                                        ),
                                      ]
                                      else ...[
                                        IconButton(
                                          icon: const Icon(Icons.save, size: 20),
                                          onPressed: () => _updateTask(index),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.cancel, size: 20),
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
                                                  ? 'Change Time (${_formatTimeOfDay(time)})' 
                                                  : 'Set Time',
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
                    child: Text(editingNoteId == null ? 'Save Batch Note' : 'Update Note'),
                  ),
                  if (editingNoteId != null) ...[
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: _cancelEditing,
                      child: const Text('Cancel'),
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
                    return const Center(
                      child: Text("No batch notes yet.", style: TextStyle(fontSize: 16)),
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
                      final createdAt = _formatTimestamp(data['createdAt']);

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
                                    ...tasks.take(3).map((task) {
                                      final time = task['time'] != null
                                          ? TimeOfDay(
                                              hour: task['time']['hour'],
                                              minute: task['time']['minute'])
                                          : null;
                                      
                                      return Row(
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
                                        ],
                                      );
                                    }),
                                    if (tasks.length > 3)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '+ ${tasks.length - 3} more tasks',
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