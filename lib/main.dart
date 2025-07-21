import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const NotepadApp());
}

class NotepadApp extends StatelessWidget {
  const NotepadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notepad App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const NotesHomePage(),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  late final CollectionReference notesCollection;
  String? editingNoteId;

  @override
  void initState() {
    super.initState();
    notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes');
  }

  void _addOrUpdateNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) return;

    // Clear controllers and reset editing state BEFORE Firestore operation
    final wasEditing = editingNoteId != null;
    _titleController.clear();
    _contentController.clear();
    editingNoteId = null;
    setState(() {}); // Update UI immediately to clear fields and reset button

    if (wasEditing) {
      await notesCollection.doc(editingNoteId).update({
        'title': title,
        'content': content,
      });
    } else {
      await notesCollection.add({
        'title': title,
        'content': content,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _toggleCompletionStatus(String docId, bool currentStatus) async {
    await notesCollection.doc(docId).update({
      'isCompleted': !currentStatus,
    });
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
              // Close dialog immediately
              Navigator.pop(context);
              
              // Check if we're deleting the note currently being edited
              final wasEditing = editingNoteId == docId;
              
              // Delete the note
              await notesCollection.doc(docId).delete();
              
              // If it was being edited, reset editing state
              if (wasEditing) {
                _titleController.clear();
                _contentController.clear();
                editingNoteId = null;
                // Force UI update to change button and clear fields
                setState(() {});
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _startEditingNote(String docId, String title, String content) {
    _titleController.text = title;
    _contentController.text = content;
    editingNoteId = docId;
    setState(() {});
  }

  void _cancelEditing() {
    _titleController.clear();
    _contentController.clear();
    editingNoteId = null;
    setState(() {});
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat.yMMMd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Notepad')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contentController,
                minLines: 3,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _addOrUpdateNote,
                    child: Text(editingNoteId == null ? 'Add Note' : 'Update Note'),
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
              StreamBuilder<QuerySnapshot>(
                stream: notesCollection.orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final notes = snapshot.data!.docs;

                  if (notes.isEmpty) {
                    return const Center(child: Text("No notes yet."));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final doc = notes[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final title = data['title'] ?? '';
                      final content = data['content'] ?? '';
                      final isCompleted = data['isCompleted'] ?? false;
                      final createdAt = _formatTimestamp(data['createdAt']);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          onTap: () => _startEditingNote(doc.id, title, content),
                          leading: Checkbox(
                            value: isCompleted,
                            onChanged: (value) => 
                                _toggleCompletionStatus(doc.id, isCompleted),
                          ),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Container(
                                constraints: const BoxConstraints(maxHeight: 100),
                                child: SingleChildScrollView(
                                  child: Text(
                                    content,
                                    style: TextStyle(
                                      fontSize: 14,
                                      decoration: isCompleted 
                                          ? TextDecoration.lineThrough 
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                createdAt,
                                style: const TextStyle(
                                  fontSize: 12, 
                                  color: Colors.grey
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDeleteNote(doc.id),
                          ),
                          isThreeLine: true,
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