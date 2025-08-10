import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/secure_storage_service.dart';

class LockedNotesPage extends StatefulWidget {
  const LockedNotesPage({super.key});

  @override
  State<LockedNotesPage> createState() => _LockedNotesPageState();
}

class _LockedNotesPageState extends State<LockedNotesPage> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final SecureStorageService _secureStorage = SecureStorageService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? editingNoteId;
  late final CollectionReference notesCollection;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes');
    _checkPasswordSetup();
  }

  Future<void> _checkPasswordSetup() async {
    final hasPassword = await _secureStorage.hasPassword();
    if (!hasPassword) {
      _showPasswordSetupDialog();
    } else {
      _showPasswordVerificationDialog();
    }
  }

  void _showPasswordSetupDialog() {
    final TextEditingController passwordController = TextEditingController();
    String? selectedQuestion;
    final TextEditingController answerController = TextEditingController();
    final List<String> securityQuestions = [
      "What is your date of birth?",
      "What is your favorite food?",
      "Which is your favorite place?"
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Set Up Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Set Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedQuestion,
              hint: const Text('Select security question'),
              items: securityQuestions.map((question) {
                return DropdownMenuItem(
                  value: question,
                  child: Text(question),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedQuestion = value;
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to Home page
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text.isEmpty || selectedQuestion == null || answerController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              await _secureStorage.setPassword(passwordController.text);
              await _secureStorage.setSecurityQuestion(selectedQuestion!, answerController.text);
              setState(() {
                _isAuthenticated = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password and security question set')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPasswordVerificationDialog() {
    _passwordController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter Password'),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to Home page
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final isValid = await _secureStorage.verifyPassword(_passwordController.text);
              if (isValid) {
                setState(() {
                  _isAuthenticated = true;
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect password')),
                );
              }
            },
            child: const Text('Submit'),
          ),
          TextButton(
            onPressed: () => _showForgotPasswordDialog(),
            child: const Text('Forgot Password'),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final TextEditingController answerController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<String?>(
        future: _secureStorage.getSecurityQuestion(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final question = snapshot.data;
          if (question == null) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Security question not set'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          }
          return AlertDialog(
            title: const Text('Security Question'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(question),
                const SizedBox(height: 10),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(
                    labelText: 'Answer',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final isValid = await _secureStorage.verifySecurityAnswer(answerController.text);
                  if (isValid) {
                    Navigator.pop(context);
                    _showResetPasswordDialog();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect answer')),
                    );
                  }
                },
                child: const Text('Verify'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showResetPasswordDialog() {
    final TextEditingController newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (newPasswordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a new password')),
                );
                return;
              }
              await _secureStorage.resetPassword(newPasswordController.text);
              setState(() {
                _isAuthenticated = true;
              });
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset successfully')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
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
      'isLocked': true,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Show SnackBar message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(wasEditing ? 'Note updated' : 'Note added')),
  );

  // Now clear the fields and reset the editing state
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
              await _secureStorage.deleteNotePassword(docId);
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

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Locked Notes', style: TextStyle(color: Colors.indigo)),
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
                    .where('isLocked', isEqualTo: true)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final notes = snapshot.data!.docs;

                  if (notes.isEmpty) {
                    return const Center(child: Text("No locked notes yet."));
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