import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_notepad/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../services/secure_storage_service.dart';
import '../services/reminder_service.dart';
import '../services/speech_service.dart';
import '../utils/note_search_utils.dart';
import '../utils/reminder_formatter.dart';
import '../utils/security_questions.dart';
import '../widgets/note_reminder_button.dart';
import '../widgets/note_search_bar.dart';
import '../widgets/voice_input_button.dart';

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
  final TextEditingController _searchController = TextEditingController();
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
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController passwordController = TextEditingController();
    String? selectedQuestion;
    final TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.setUpPassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.setPassword,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedQuestion,
              hint: Text(l10n.selectSecurityQuestion),
              items: SecurityQuestions.keys.map((question) {
                return DropdownMenuItem(
                  value: question,
                  child: Text(SecurityQuestions.label(l10n, question)),
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
              decoration: InputDecoration(
                labelText: l10n.answer,
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
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text.isEmpty || selectedQuestion == null || answerController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.pleaseFillAllFields)),
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
                SnackBar(content: Text(l10n.passwordSecuritySet)),
              );
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showPasswordVerificationDialog() {
    final l10n = AppLocalizations.of(context)!;
    _passwordController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.enterPassword),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.password,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to Home page
            },
            child: Text(l10n.cancel),
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
                  SnackBar(content: Text(l10n.incorrectPassword)),
                );
              }
            },
            child: Text(l10n.submit),
          ),
          TextButton(
            onPressed: () => _showForgotPasswordDialog(),
            child: Text(l10n.forgotPassword),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final l10n = AppLocalizations.of(context)!;
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
              title: Text(l10n.error),
              content: Text(l10n.securityQuestionNotSet),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.ok),
                ),
              ],
            );
          }
          return AlertDialog(
            title: Text(l10n.securityQuestion),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(SecurityQuestions.displayLabel(l10n, question)),
                const SizedBox(height: 10),
                TextField(
                  controller: answerController,
                  decoration: InputDecoration(
                    labelText: l10n.answer,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () async {
                  final isValid = await _secureStorage.verifySecurityAnswer(answerController.text);
                  if (isValid) {
                    Navigator.pop(context);
                    _showResetPasswordDialog();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.incorrectAnswer)),
                    );
                  }
                },
                child: Text(l10n.verify),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showResetPasswordDialog() {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetPassword),
        content: TextField(
          controller: newPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.newPassword,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (newPasswordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.pleaseEnterNewPassword)),
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
                SnackBar(content: Text(l10n.passwordResetSuccess)),
              );
            },
            child: Text(l10n.resetPassword),
          ),
        ],
      ),
    );
  }

  void _addOrUpdateNote() async {
  final l10n = AppLocalizations.of(context)!;
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
    SnackBar(content: Text(wasEditing ? l10n.noteUpdated : l10n.noteAdded)),
  );

  await SpeechService.instance.stopAny();
  _titleController.clear();
  _contentController.clear();
  editingNoteId = null;
  setState(() {});
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
              await ReminderService.instance.cancelReminder(docId);
              await notesCollection.doc(docId).delete();
              await _secureStorage.deleteNotePassword(docId);
              if (editingNoteId == docId) {
                _titleController.clear();
                _contentController.clear();
                editingNoteId = null;
                setState(() {});
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
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

  void _cancelEditing() async {
    await SpeechService.instance.stopAny();
    _titleController.clear();
    _contentController.clear();
    editingNoteId = null;
    setState(() {});
  }

  String _formatTimestamp(Timestamp? timestamp, String localeName) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat.yMMMd(localeName).add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_isAuthenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(l10n.lockedNotes, style: const TextStyle(color: Colors.indigo)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: NoteSearchBar(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            hintText: l10n.searchLockedNotes,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  border: const OutlineInputBorder(),
                  suffixIcon: VoiceInputButton(controller: _titleController),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contentController,
                minLines: 3,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: l10n.content,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                  suffixIcon: VoiceInputButton(controller: _contentController),
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
                    child: Text(editingNoteId == null ? l10n.addNote : l10n.updateNote),
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
                  final filteredNotes = notes.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return noteMatchesSearch(data, _searchController.text);
                  }).toList();

                  if (notes.isEmpty) {
                    return Center(child: Text(l10n.noLockedNotesYet));
                  }

                  if (filteredNotes.isEmpty) {
                    return Center(child: Text(l10n.noLockedNotesMatchSearch));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final doc = filteredNotes[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final title = data['title'] ?? '';
                      final content = data['content'] ?? '';
                      final isCompleted = data['isCompleted'] ?? false;
                      final createdAt =
                          _formatTimestamp(data['createdAt'], l10n.localeName);
                      final reminderAt = data['reminderAt'] as Timestamp?;
                      final reminderRepeat =
                          data['reminderRepeat'] as String?;

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
                              if (reminderAt != null)
                                Text(
                                  l10n.reminderLabel(
                                    ReminderFormatter.formatReminderLabel(
                                      l10n,
                                      reminderAt,
                                      reminderRepeat,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              Text(
                                createdAt,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NoteReminderButton(
                                notesCollection: notesCollection,
                                noteId: doc.id,
                                noteTitle: title,
                                noteContent: content,
                                reminderAt: reminderAt,
                                reminderRepeat: reminderRepeat,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDeleteNote(doc.id),
                              ),
                            ],
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