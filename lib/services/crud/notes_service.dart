import 'package:flutter/foundation.dart';
import 'package:notes_app/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

// extension for logging
import 'dart:developer' as devtools show log;

// to show log
extension Log on Object {
  void log() => devtools.log(toString());
}

class NotesService {
  Database? _database;

  Future<DatabaseNotes> updateNote({
    required DatabaseNotes note,
    required String text,
  }) async {
    final database = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updateCount = await database.update(notesTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    final database = _getDatabaseOrThrow();
    final notes = await database.query(notesTable);

    return notes.map((notesRow) => DatabaseNotes.fromRow(notesRow));
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    final database = _getDatabaseOrThrow();
    final notes = await database.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    return notes.isEmpty
        ? throw CouldNotFindNote()
        : DatabaseNotes.fromRow(notes.first);
  }

  Future<int> deleteAllNotes() async {
    final database = _getDatabaseOrThrow();
    return await database.delete(notesTable);
  }

  Future<void> deleteNote({required int id}) async {
    final database = _getDatabaseOrThrow();
    final deletedCount = await database.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
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
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
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
      results.log();
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUsers({required String email}) async {
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

@immutable
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
      'Note, ID = $id, UserID = $userId, Text = $text, isSyncedWithCloud: $isSyncedWithCloud';

  // Equality
  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const databaseName = 'notes.db';

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
      "text"	TEXT NOT NULL,
      "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY("user_id") REFERENCES "user"("id"),
      PRIMARY KEY("id" AUTOINCREMENT)
      );''';
