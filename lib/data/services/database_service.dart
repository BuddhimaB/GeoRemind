import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../models/reminder_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  
  DatabaseService._init();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }
  
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);
    
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
    );
  }
  
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        locationName TEXT NOT NULL,
        radius REAL NOT NULL,
        isActive INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        triggeredAt TEXT,
        priority INTEGER NOT NULL,
        category TEXT,
        color INTEGER
      )
    ''');
    
    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_reminders_isActive ON reminders(isActive)
    ''');
  }
  
  Future<List<ReminderModel>> getAllReminders() async {
    final db = await database;
    final result = await db.query(
      'reminders',
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => ReminderModel.fromMap(map)).toList();
  }
  
  Future<List<ReminderModel>> getActiveReminders() async {
    final db = await database;
    final result = await db.query(
      'reminders',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => ReminderModel.fromMap(map)).toList();
  }
  
  Future<ReminderModel?> getReminderById(String id) async {
    final db = await database;
    final result = await db.query(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (result.isEmpty) return null;
    return ReminderModel.fromMap(result.first);
  }
  
  Future<void> insertReminder(ReminderModel reminder) async {
    final db = await database;
    await db.insert(
      'reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<void> updateReminder(ReminderModel reminder) async {
    final db = await database;
    await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }
  
  Future<void> deleteReminder(String id) async {
    final db = await database;
    await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> toggleReminderActive(String id, bool isActive) async {
    final db = await database;
    await db.update(
      'reminders',
      {'isActive': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
