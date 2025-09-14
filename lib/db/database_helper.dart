import 'dart:io';
import 'package:file_picker/file_picker.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/filato.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('filati.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE filati (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        peso INTEGER NOT NULL,
        metraggio INTEGER,
        compratoDa TEXT,
        quantitaPosseduta INTEGER NOT NULL,
        colore TEXT,
        spessoriUncinetto TEXT,
        posizione TEXT,
        dataAcquisto TEXT,
        materiale TEXT NOT NULL
      )
    ''');
  }

  // INSERT
  Future<int> insertFilato(Filato filato) async {
    final db = await instance.database;
    return await db.insert('filati', filato.toMap());
  }

  // READ ALL
  Future<List<Filato>> getAllFilati() async {
    final db = await instance.database;
    final result = await db.query('filati');
    return result.map((map) => Filato.fromMap(map)).toList();
  }

  // UPDATE
  Future<int> updateFilato(Filato filato) async {
    final db = await instance.database;
    return await db.update(
      'filati',
      filato.toMap(),
      where: 'id = ?',
      whereArgs: [filato.id],
    );
  }

  // DELETE
  Future<int> deleteFilato(int id) async {
    final db = await instance.database;
    return await db.delete(
      'filati',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CLOSE
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> exportDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, 'filati.db');
    final dbFile = File(dbPath);

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final backupPath = join(selectedDirectory, 'bakcup_filati.db');
      await dbFile.copy(backupPath);
    }
  }

  Future<void> importDatabase() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['db']);
  if (result != null) {
    final selectedPath = result.files.single.path;
    if (selectedPath != null) {
      final databasesPath = await getDatabasesPath();
      final dbPath = join(databasesPath, 'nome_del_tuo_database.db');
      final dbFile = File(dbPath);
      await dbFile.delete();
      await File(selectedPath).copy(dbPath);
    }
  }
}
}
