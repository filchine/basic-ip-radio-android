import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/radio_station.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;
  static Future<Database>? _initFuture;

  factory DbHelper() => _instance;

  DbHelper._internal();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _initFuture ??= _initDb();
    _database = await _initFuture;
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'radio_stations.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS radio_stations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        stream_url TEXT NOT NULL,
        image_url TEXT NOT NULL,
        is_favorite INTEGER DEFAULT 0,
        position INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      var tableInfo = await db.rawQuery('PRAGMA table_info(radio_stations)');
      if (!tableInfo.any((column) => column['name'] == 'is_favorite')) {
        await db.execute('ALTER TABLE radio_stations ADD COLUMN is_favorite INTEGER DEFAULT 0');
      }
    }
    if (oldVersion < 3) {
      var tableInfo = await db.rawQuery('PRAGMA table_info(radio_stations)');
      if (!tableInfo.any((column) => column['name'] == 'position')) {
        await db.execute('ALTER TABLE radio_stations ADD COLUMN position INTEGER DEFAULT 0');
      }
    }
  }

  Future<int> insertStation(RadioStation station) async {
    try {
      Database db = await database;
      return await db.insert('radio_stations', station.toMap());
    } catch (e) {
      print("Error inserting station: $e");
      return -1;
    }
  }

  Future<List<RadioStation>> getStations() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query('radio_stations', orderBy: 'position ASC');
      return maps.map((map) => RadioStation.fromMap(map)).toList();
    } catch (e) {
      print("Error getting stations: $e");
      return [];
    }
  }

  Future<int> updateStation(RadioStation station) async {
    try {
      Database db = await database;
      return await db.update(
        'radio_stations',
        station.toMap(),
        where: 'id = ?',
        whereArgs: [station.id],
      );
    } catch (e) {
      print("Error updating station: $e");
      return -1;
    }
  }

  Future<int> deleteStation(int id) async {
    try {
      Database db = await database;
      return await db.delete(
        'radio_stations',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error deleting station: $e");
      return -1;
    }
  }
}
