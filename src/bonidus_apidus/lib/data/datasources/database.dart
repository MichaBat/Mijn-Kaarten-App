import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

String databaseName = "demo.db";

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _databaseHelper;
  }
  DatabaseHelper._internal();

  Future<Database> get db async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, databaseName);

    return await openDatabase(
      path,
      version: 3,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE BRANDS (
      id INTEGER PRIMARY KEY,
      domain VARCHAR(255) NOT NULL,
      logo_path VARCHAR(225),
      name VARCHAR(255)
    )
    ''');

    await db.execute('''
    CREATE TABLE BRAND_COLOURS (
      id INTEGER PRIMARY KEY,
      brand_id INTEGER NOT NULL,
      color_hex VARCHAR(8) NOT NULL,
      type VARCHAR(100),
      brightness INTEGER,
      FOREIGN KEY (brand_id) REFERENCES BRANDS(id)
    )
    ''');

    await db.execute('''
    CREATE TABLE CARDS(
      id INTEGER PRIMARY KEY,
      title VARCHAR(255),
      domain VARCHAR(255),
      logo_path VARCHAR(225),
      code_value TEXT,
      code_format VARCHAR(50),
      brand_id INTEGER,
      is_pinned INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (brand_id) REFERENCES BRANDS(id)
    )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE CARDS ADD COLUMN code_value TEXT');
      await db.execute('ALTER TABLE CARDS ADD COLUMN code_format VARCHAR(50)');
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE CARDS ADD COLUMN is_pinned INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<int> insertCard(Card card) async {
    Database db = await this.db;
    return await db.insert('CARDS', card.toMap());
  }

  Future<List<Map<String, dynamic>>> getCards() async{
    Database db = await this.db;
    return await db.query('CARDS');
  }

  Future<List<Map<String, dynamic>>> getCard() async{
    Database db = await this.db;
    return await db.query('CARDS');
  }

  Future<int> updateCard(Card card) async {
    Database db = await this.db;
    return await db.update('CARDS', card.toMap(), where: 'id = ?', whereArgs: [card.id]);
  }

  Future<int> deleteCard(int id) async {
    Database db = await this.db;
    return await db.delete('CARDS', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllCards() async {
    Database db = await this.db;
    return await db.delete('CARDS');
  }

  Future<int> setCardPinned(int id, bool pinned) async {
    Database db = await this.db;
    return await db.update(
      'CARDS',
      {'is_pinned': pinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertBrand(Brand brand) async {
    Database db = await this.db;
    return await db.insert('BRANDS', brand.toMap());
  }

  Future<List<Map<String, dynamic>>> getBrandByDomain(String domain) async{
    Database db = await this.db;
    return await db.query('BRANDS', where: 'domain=?', whereArgs: [domain]);
  }


  Future<int> insertBrandColour(BrandColour brandColour) async {
    Database db = await this.db;
    return await db.insert('BRAND_COLOURS', brandColour.toMap());
  }

  Future<List<Map<String, dynamic>>> getBrandColoursByBrandId(int brandId) async {
    Database db = await this.db;
    return await db.query('BRAND_COLOURS', where: 'brand_id = ?', whereArgs: [brandId]);
  }

  Future<void> deleteDatabaseFile() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, databaseName);
    await deleteDatabase(path);
  }

}
