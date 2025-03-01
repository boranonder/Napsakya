import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/question.dart';

class DatabaseHelper {
  // Singleton yapısı için `instance` değişkeni ekliyoruz.
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // Private constructor (özel yapıcı) ile singleton yapısı sağlanıyor.
  DatabaseHelper._internal();

  // Factory constructor, her zaman aynı instance'ı döndürür.
  factory DatabaseHelper() {
    return instance;
  }

  static Database? _database;

  // Veritabanını oluşturma veya mevcut veritabanını getirme.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Veritabanını başlatma ve tabloyu oluşturma işlemi.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'questions_database.db'); // Veritabanı dosya yolu
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      //onUpgrade: _onUpgrade, // Versiyon güncellemeleri için onUpgrade fonksiyonu ekleyelim
    );
  }
  Future<List<Question>> getQuestionsByMode(String mode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'mode = ?',
      whereArgs: [mode],
    );
    return maps.isNotEmpty
        ? maps.map((question) => Question.fromMap(question)).toList()
        : [];
  }
  // database_helper.dart
  Future<int> updateFavoriteStatus(int questionId, bool isFav) async {
    final db = await database;
    return await db.update(
      'questions',
      {'isFav': isFav ? 1 : 0},
      where: 'id = ?',
      whereArgs: [questionId],
    );
  }


  // İlk kez veritabanı oluşturulurken tabloyu oluşturma işlemi.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL, 
        isFav INTEGER NOT NULL,
        mode TEXT NOT NULL
      )
    ''');
  }

  // Eğer veritabanı versiyonu yükseltilirse bu fonksiyon çalıştırılır.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Veritabanında değişiklikler yapmanız gerekirse buraya ekleyebilirsiniz.
      await db.execute('DROP TABLE IF EXISTS questions');
      await _onCreate(db, newVersion);
    }
  }

  // Veritabanına yeni bir soru ekleme
  Future<int> insertQuestion(Question question) async {
    Database db = await database;
    return await db.insert(
      'questions',
      question.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Veritabanından tüm soruları getirme
  Future<List<Question>> getQuestions() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('questions');
    return maps.isNotEmpty
        ? maps.map((question) => Question.fromMap(question)).toList()
        : [];
  }

  // Favori soruları getirme
  Future<List<Question>> getFavoriteQuestions() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'isFav = ?',
      whereArgs: [1],
    );

    return maps.isNotEmpty
        ? maps.map((question) => Question.fromMap(question)).toList()
        : [];
  }

  // Soru güncelleme
  Future<int> updateQuestion(Question question) async {
    Database db = await database;
    return await db.update(
      'questions',
      question.toMap(),
      where: 'id = ?',
      whereArgs: [question.id],
    );
  }

  // Soru silme
  Future<void> deleteQuestion(int id) async {
    Database db = await database;
    await db.delete(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tüm soruları silme (Opsiyonel)
  Future<void> deleteAllQuestions() async {
    Database db = await database;
    await db.delete('questions');
  }

  // Veritabanını kapatma
  Future<void> close() async {
    Database db = await database;
    await db.close();
  }

}

