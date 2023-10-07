import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesScreen extends StatefulWidget {
  final User user;

  NotesScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<NotesScreen> {
  final TextEditingController _noteController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String id = "";
  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _addNote() async {
    String noteText = _noteController.text;
    if (noteText.isNotEmpty) {
      await _firestore.collection('notes').add({
        'userId': widget.user.uid,
        'text': noteText,
      });
      _noteController.clear();
    }
  }

  void _editNote(String noteId, String newText) async {
    await _firestore.collection('notes').doc(noteId).update({'text': newText});
  }

  

  void _deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              _signOut();
              //Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Enter a new note',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addNote,
            child: const Text('Add Note'),
          ),
          ElevatedButton(
            onPressed: () {
              if (id != "") {
                _editNote(id, _noteController.text);
                id = "";
              }
            },
            child: const Text('Update Note'),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('notes')
                .where('userId', isEqualTo: widget.user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator(); // Handle loading state
              }
              List<QueryDocumentSnapshot> notes = snapshot.data!.docs;
              return Expanded(
                child: ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final noteId = note.id;
                    final noteText = note['text'];
                    return ListTile(
                      title: Text(noteText),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                _noteController.text = noteText;
                                id = noteId;
                              });
                              // Show an edit dialog and update the note
                              // showDialog(
                              //   context: context,
                              //   builder: (context) {
                              //     TextEditingController _editController =
                              //         TextEditingController(text: noteText);
                              //     return AlertDialog(
                              //       title: Text('Edit Note'),
                              //       content: TextField(
                              //         controller: _editController,
                              //       ),
                              //       actions: [
                              //         TextButton(
                              //           onPressed: () {
                              //             Navigator.of(context).pop();
                              //           },
                              //           child: Text('Cancel'),
                              //         ),
                              //         TextButton(
                              //           onPressed: () {
                              //             String newText = _editController.text;
                              //             if (newText.isNotEmpty) {
                              //               _editNote(noteId, newText);
                              //               Navigator.of(context).pop();
                              //             }
                              //           },
                              //           child: Text('Save'),
                              //         ),
                              //       ],
                              //     );
                              //   },
                              //);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Confirm the delete operation and delete the note
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Confirm Delete'),
                                    content: Text(
                                        'Are you sure you want to delete this note?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _deleteNote(noteId);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
