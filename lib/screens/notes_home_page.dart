import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_notepad/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'batch_notes_page.dart';
import '../services/reminder_service.dart';
import '../services/speech_service.dart';
import '../services/widget_service.dart';
import '../services/update_notification_service.dart';
import '../utils/reminder_formatter.dart';
import '../utils/note_search_utils.dart';
import '../widgets/note_reminder_button.dart';
import '../widgets/note_search_bar.dart';
import '../widgets/voice_input_button.dart';

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  late final CollectionReference notesCollection;
  String? editingNoteId;
  bool _isBatchMode = false;
  bool _showWidgetTip = false;

  @override
  void initState() {
    super.initState();
    notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes');
    _loadWidgetTip();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForAppUpdate();
    });
  }

  Future<void> _checkForAppUpdate() async {
    await UpdateNotificationService.instance.checkForProductionUpdate(
      onInAppPrompt: (info) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(info.title),
            content: Text(info.body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  UpdateNotificationService.instance.openPlayStore();
                },
                child: Text(l10n.install),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadWidgetTip() async {
    try {
      final show = await WidgetService.instance.shouldShowHomeTip();
      if (mounted) {
        setState(() => _showWidgetTip = show);
      }
    } catch (_) {
      // Ignore tip load errors.
    }
  }

  Future<void> _dismissWidgetTip() async {
    await WidgetService.instance.dismissHomeTip();
    if (mounted) {
      setState(() => _showWidgetTip = false);
    }
  }

  void _openWidgetSetup() {
    Navigator.pushNamed(context, '/widget-setup');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    super.dispose();
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
        'isLocked': false,
        'isCompleted': false,
        'isBatch': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(wasEditing ? l10n.noteUpdated : l10n.noteAdded)),
      );
    }

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

  void _inviteFriends(AppLocalizations l10n) {
    Share.share(
      l10n.inviteShareText,
      subject: l10n.inviteShareSubject,
    );
  }

  void _sendFeedback(AppLocalizations l10n) {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'vvmh2014@gmail.com',
    );

    launchUrl(emailLaunchUri).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotLaunchEmail)),
        );
      }
      return false;
    });
  }

  Future<void> _rateApp(AppLocalizations l10n) async {
    const packageId = 'com.viveksingh.notepad_app';
    final marketUri = Uri.parse('market://details?id=$packageId');
    final webUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageId',
    );

    if (await canLaunchUrl(marketUri)) {
      await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotOpenPlayStore)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(l10n.appTitle, style: const TextStyle(color: Colors.indigo)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: NoteSearchBar(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            hintText: l10n.searchNotes,
          ),
        ),
        actions: [
          Row(
            children: [
              Text(l10n.batchMode),
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
              } else if (value == 'our-apps') {
                Navigator.pushNamed(context, '/our-apps');
              } else if (value == 'widget-setup') {
                _openWidgetSetup();
              } else if (value == 'invite') {
                _inviteFriends(l10n);
              } else if (value == 'feedback') {
                _sendFeedback(l10n);
              } else if (value == 'language') {
                Navigator.pushNamed(context, '/language');
              } else if (value == 'rate-us') {
                _rateApp(l10n);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'locked-notes',
                child: Row(
                  children: [
                    Icon(Icons.lock),
                    SizedBox(width: 8),
                    Text(l10n.lockedNotes),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'widget-setup',
                child: Row(
                  children: [
                    Icon(Icons.widgets),
                    SizedBox(width: 8),
                    Text(l10n.homeScreenWidget),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'our-apps',
                child: Row(
                  children: [
                    Icon(Icons.apps),
                    SizedBox(width: 8),
                    Text(l10n.ourNewApps),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'invite',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text(l10n.inviteFriends),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'feedback',
                child: Row(
                  children: [
                    Icon(Icons.feedback),
                    SizedBox(width: 8),
                    Text(l10n.sendFeedback),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'language',
                child: Row(
                  children: [
                    const Icon(Icons.language),
                    const SizedBox(width: 8),
                    Text(l10n.language),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'rate-us',
                child: Row(
                  children: [
                    Icon(Icons.star),
                    SizedBox(width: 8),
                    Text(l10n.rateUs),
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
              if (_showWidgetTip)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.indigo.shade50,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.widgets, color: Colors.indigo),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.addNotesToHomeScreen,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.widgetTipDescription,
                                style: TextStyle(fontSize: 13),
                              ),
                              TextButton(
                                onPressed: _openWidgetSetup,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(l10n.setUpWidget),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: _dismissWidgetTip,
                          tooltip: l10n.dismiss,
                        ),
                      ],
                    ),
                  ),
                ),
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
                    .where('isLocked', isEqualTo: false)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final notes = snapshot.data!.docs;
                  WidgetService.instance.updateFromNotes(notes);

                  final regularNotes = notes.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['isBatch'] != true;
                  }).toList();

                  final filteredNotes = regularNotes.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return noteMatchesSearch(data, _searchController.text);
                  }).toList();

                  if (regularNotes.isEmpty) {
                    return Center(child: Text(l10n.noNotesYet));
                  }

                  if (filteredNotes.isEmpty) {
                    return Center(child: Text(l10n.noNotesMatchSearch));
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
                            onChanged: (value) =>
                                notesCollection.doc(doc.id).update({
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
                                constraints:
                                    const BoxConstraints(maxHeight: 100),
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
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
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
