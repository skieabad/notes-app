import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:notes_app/extensions/list/filter.dart';
import 'package:notes_app/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class NotesService {
  Database? _database;

  // source of truth
  List<DatabaseNotes> _notes = [];

  DatabaseUser? _user;

  // create a singleton
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNotes>>.broadcast(
      // called whenever a new listener subscribe to the notesStreamController
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  // this factory constructor called when NotesService is called
  //
  factory NotesService() => _shared;

  // control the changes of the notes list
  // read from the ui
  late final StreamController<List<DatabaseNotes>> _notesStreamController;

  Stream<List<DatabaseNotes>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          // checking if the userID of note database is equal to the userID of the current user
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUsers(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  // Read all the notes in the database and place them in the notes list
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();

    // convert iterable into a list
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNotes> updateNote({
    required DatabaseNotes note,
    required String text,
  }) async {
    await _ensureDatabaseIsOpen();
    final database = _getDatabaseOrThrow();

    // ! make sure not exists
    await getNote(id: note.id);

    // ! update database
    final updateCount = await database.update(
      notesTable,
      {
        textColumn: text,
        isSyncedWithCloudColumn: 0,
      },
      // always put a where clause
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    await _ensureDatabaseIsOpen();
    final database = _getDatabaseOrThrow();
    final notes = await database.query(notesTable);

    return notes.map((notesRow) => DatabaseNotes.fromRow(notesRow));
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await _ensureDatabaseIsOpen();
    final database = _getDatabaseOrThrow();
    final notes = await database.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNotes.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDatabaseIsOpen();
    final database = _getDatabaseOrThrow();
    final numberOfDeletions = await database.delete(notesTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDatabaseIsOpen();
    final database = _getDatabaseOrThrow();
    final deletedCount = await database.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((notes) => notes.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    await _ensureDatabaseIsOpen();
    final database = _getDatabaseOrThrow();

    // make sure that the owner exists in the database with the correct id
    final databaseUser = await getUser(email: owner.email);

    if (databaseUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
    // create the note
    final noteId = await database.insert(
      notesTable,
      {
        userIdColumn: owner.id,
        textColumn: text,
        isSyncedWithCloudColumn: 1,
      },
    );
    final note = DatabaseNotes(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDatabaseIsOpen();
    final database = _getDatabaseOrThrow();
    final results = await database.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    // either 0 or 1 results
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUsers({required String email}) async {
    await _ensureDatabaseIsOpen();
    final database = _getDatabaseOrThrow();
    final results = await database.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await database.insert(
      userTable,
      // key and values
      {
        emailColumn: email.toLowerCase(),
      },
    );

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDatabaseIsOpen();
    final database = _getDatabaseOrThrow();
    final deletedCount = await database.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final database = _database;
    if (database == null) {
      throw DatabaseIsNotOpen();
    } else {
      return database;
    }
  }

  Future<void> close() async {
    final database = _database;
    if (database == null) {
      throw DatabaseIsNotOpen();
    } else {
      await database.close();
      _database = null;
    }
  }

  Future<void> _ensureDatabaseIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> open() async {
    if (_database != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = join(directory.path, databaseName);
      final database = await openDatabase(path);
      _database = database;

      // ? Create the user table
      await database.execute(createUserTable);

      // ? Create the notes table
      await database.execute(createNotesTable);

      // ? Read all notes upon opening the database
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  // Equality
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

  // Equality
  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const databaseName = 'backend.db';

// user table
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	    "id"	INTEGER NOT NULL,
	    "email"	TEXT NOT NULL UNIQUE,
	    PRIMARY KEY("id" AUTOINCREMENT)
      );''';

// notes table
const notesTable = 'notes';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createNotesTable = '''CREATE TABLE IF NOT EXISTS "notes" (
	    "id"	INTEGER NOT NULL,
	    "user_id"	INTEGER NOT NULL,
	    "text"	TEXT,
	    "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	    FOREIGN KEY("user_id") REFERENCES "user"("id"),
	    PRIMARY KEY("id" AUTOINCREMENT)
      );''';
