import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final notesQuery = FirebaseFirestore.instance
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Search by title'),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: notesQuery,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final notes = snapshot.data!.docs.where((doc) {
                  final title = doc['title']?.toString().toLowerCase() ?? '';
                  return title.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final doc = notes[index];
                    return ListTile(
                      title: Text(doc['title']),
                      subtitle: Text(doc['content']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddNoteScreen(
                              docId: doc.id,
                              existingTitle: doc['title'],
                              existingContent: doc['content'],
                            ),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddNoteScreen(
                                docId: doc.id,
                                existingTitle: doc['title'],
                                existingContent: doc['content'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddNoteScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
