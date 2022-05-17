import 'package:flutter/material.dart';
import 'package:notes_app/services/crud/notes_service.dart';

typedef DeleteNoteCallback = void Function(DatabaseNotes note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNotes> notes;
  final DeleteNoteCallback onDeleteNote;
  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(
            note.text,
            // if you want to break the text into multiple lines
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () {
              // final shouldDelete = await showDeleteDialog(context);
              // if (shouldDelete) {
              //   onDeleteNote(note);
              // }
            },
            icon: const Icon(
              Icons.delete,
            ),
          ),
        );
      },
    );
  }
}
