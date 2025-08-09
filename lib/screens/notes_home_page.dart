import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'batch_notes_page.dart';

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
  bool _isBatchMode = false;

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

    final wasEditing = editingNoteId != null;

    if (wasEditing) {
      await notesCollection.doc(editingNoteId).update({
        'title': title,
        'content': content,
      });
    } else {
      await notesCollection.add({
        'title': title,
        'content': content,
        'isLocked': false,
        'isCompleted': false,
        'isBatch': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(wasEditing ? 'Note updated' : 'Note added')),
    );

    _titleController.clear();
    _contentController.clear();
    editingNoteId = null;
    setState(() {});
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
                _titleController.clear();
                _contentController.clear();
                editingNoteId = null;
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

  void _navigateToBatchNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BatchNotesPage(resetBatchMode: resetBatchMode),
      ),
    );
  }

  void resetBatchMode() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isBatchMode = false;
        });
      }
    });
  }

  void _inviteFriends() {
    Share.share(
      'Check out this awesome Secure Notepad app! It helps me stay organized and secure my notes.\n\nDownload it here: [Your App Store Link]',
      subject: 'Try Secure Notepad App',
    );
  }

  void _sendFeedback() {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'vvmh2014@gmail.com',
    );

    launchUrl(emailLaunchUri).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email client')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Secure Notepad', style: TextStyle(color: Colors.indigo)),
        actions: [
          Row(
            children: [
              const Text('Batch Mode'),
              Switch(
                value: _isBatchMode,
                onChanged: (value) {
                  setState(() {
                    _isBatchMode = value;
                    if (_isBatchMode) {
                      _navigateToBatchNotes();
                    }
                  });
                },
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'locked-notes') {
                Navigator.pushNamed(context, '/locked-notes');
              } else if (value == 'invite') {
                _inviteFriends();
              } else if (value == 'feedback') {
                _sendFeedback();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'locked-notes',
                child: Row(
                  children: [
                    Icon(Icons.lock),
                    SizedBox(width: 8),
                    Text('Locked Notes'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'invite',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Invite friends to the app'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'feedback',
                child: Row(
                  children: [
                    Icon(Icons.feedback),
                    SizedBox(width: 8),
                    Text('Send feedback'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
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
                stream: notesCollection
                    .where('isLocked', isEqualTo: false)
                    .where('isBatch', isEqualTo: false)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
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
                            onChanged: (value) => notesCollection.doc(doc.id).update({
                              'isCompleted': value ?? false,
                            }),
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
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
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