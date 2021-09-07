import 'dart:developer';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final instance = AppDatabase._init();
  static Database? _database;
  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDb('mseller.db');

    return _database!;
  }

  Future<Database> _initDb(String fileName) async {
    final appPath = await getApplicationDocumentsDirectory();
    final databasePath = path.join(appPath.path, fileName);
    return openDatabase(databasePath, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    log("creando db");

    await db.transaction((txn) async {
      // TABLAS COMUNES

      await txn.execute("""
        CREATE TABLE status(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL
        );
      """);

      await txn.execute("""
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fullname TEXT NOT NULL,
          username TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          created_date integer NOT NULL,
          status_id INTEGER NOT NULL REFERENCES status(id)
        );
      """);

      await txn.execute("""
        CREATE TABLE amount_types(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL,
          status_id INTEGER NOT NULL REFERENCES status(id)
        );
      """);

      await txn.execute("""
        CREATE TABLE amounts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount_type INTEGER NOT NULL REFERENCES amount_types(id),
          description TEXT NOT NULL,
          amount TEXT NOT NULL,
          effective_date integer NOT NULL,
          created_date integer NOT NULL,
          created_by INTEGER NOT NULL REFERENCES users(id),
          status_id INTEGER NOT NULL REFERENCES status(id)
        );
      """);

      await txn.rawQuery("""
        INSERT INTO STATUS(id,description) VALUES(1,'ACTIVO');
      """);
      await txn.rawQuery("""
        INSERT INTO STATUS(id,description) VALUES(2,'INACTIVO');
      """);
      await txn.rawQuery("""
        INSERT INTO STATUS(id,description) VALUES(3,'BORRADO');
      """);

      await txn.rawQuery("""
        INSERT INTO amount_types(id,description,status_id) 
        VALUES(1,'POSITIVO',1);
      """);
      await txn.rawQuery("""
        INSERT INTO amount_types(id,description,status_id) 
        VALUES(2,'NEGATIVO',1);
      """);

      await txn.rawQuery("""
        INSERT INTO USERS(id,fullname,username,password,created_date,status_id) 
        VALUES(1,'ADMINISTRADOR', 'admin', 'admin', ${DateTime.now().microsecondsSinceEpoch},1);
      """);
    });
  }

  Future<void> close() async {
    final database = await instance.database;
    return database.close();
  }
}
