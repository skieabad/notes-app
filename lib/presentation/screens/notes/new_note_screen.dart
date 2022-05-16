import 'package:flutter/material.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/services/crud/notes_service.dart';

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen({Key? key}) : super(key: key);

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
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
  Future<DatabaseNotes> createNewNotes() async {
    final existingNote = _notes;
    if (existingNote != null) {
      return existingNote;
    }
    // get the current user
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
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
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder(
              future: createNewNotes(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    // get our notes from the snapshot
                    _notes = snapshot.data as DatabaseNotes;
                    _setupTextControllerListener();
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 20),
                      child: TextFormField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                            hintText: 'Enter your text here'),
                        maxLength: 100,
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
          ],
        ),
      ),
    );
  }
}
