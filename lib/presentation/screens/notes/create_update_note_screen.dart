import 'package:flutter/material.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/services/crud/notes_service.dart';
import 'package:notes_app/utilities/generics/get_arguments.dart';

class CreateUpdateNoteScreen extends StatefulWidget {
  const CreateUpdateNoteScreen({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteScreen> createState() => _CreateUpdateNoteScreenState();
}

class _CreateUpdateNoteScreenState extends State<CreateUpdateNoteScreen> {
  DatabaseNotes? _notes;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final notes = _notes;
    if (notes == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      note: notes,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    // create an add listener if this function is called multiple times
    _textController.addListener(_textControllerListener);
  }

  // create new notes
  Future<DatabaseNotes> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNotes>();

    if (widgetNote != null) {
      _notes = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _notes;
    if (existingNote != null) {
      return existingNote;
    }
    // get the current user
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    final newNote = await _notesService.createNote(owner: owner);
    // saving the new note
    _notes = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final notes = _notes;
    if (_textController.text.isEmpty && notes != null) {
      _notesService.deleteNote(id: notes.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    // get the notes
    final notes = _notes;
    final text = _textController.text;
    if (notes != null && text.isNotEmpty) {
      await _notesService.updateNote(
        note: notes,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New note'),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: TextFormField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Enter your text here',
                  ),
                  maxLines: null,
                ),
              );
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
