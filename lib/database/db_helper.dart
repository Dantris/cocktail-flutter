import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/cocktail.dart';
import '../models/ingredient.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("cocktail.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print("Database path: $path");

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cocktails (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        category TEXT,
        glassType TEXT,
        instructions TEXT,
        tags TEXT,
        imageUrl TEXT,
        ingredients TEXT,
        rating REAL
      )
    ''');
    print("Tables created in database.");
  }

  Future<void> insertCocktail(Cocktail cocktail) async {
    final db = await instance.database;
    final cocktailData = cocktail.toMap();
    cocktailData['ingredients'] = jsonEncode(
        cocktail.ingredients.map((ingredient) => ingredient.toMap()).toList());

    await db.insert(
      'cocktails',
      cocktailData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(
        "Inserted cocktail: ${cocktail.name} with ingredients: ${cocktailData['ingredients']}");
  }

  Future<void> updateCocktail(Cocktail cocktail) async {
    final db = await instance.database;
    final cocktailData = cocktail.toMap();
    cocktailData['ingredients'] = jsonEncode(
        cocktail.ingredients.map((ingredient) => ingredient.toMap()).toList());

    await db.update(
      'cocktails',
      cocktailData,
      where: 'id = ?',
      whereArgs: [cocktail.id],
    );
    print("Updated cocktail: ${cocktail.name}");
  }

  Future<List<Cocktail>> fetchAllCocktails() async {
    print("fetchAllCocktails called");

    final db = await instance.database;
    final cocktailMaps = await db.query('cocktails');

    List<Cocktail> cocktails = cocktailMaps.map((cocktailMap) {
      print("Fetched cocktail: ${cocktailMap['name']}");

      final ingredientsJson = cocktailMap['ingredients'] as String?;
      final tagsJson = cocktailMap['tags'] as String?;

      List<Ingredient> ingredients =
          ingredientsJson != null && ingredientsJson.isNotEmpty
              ? (jsonDecode(ingredientsJson) as List)
                  .map((ingredientMap) => Ingredient.fromMap(ingredientMap))
                  .toList()
              : [];

      List<String> tags = tagsJson != null && tagsJson.isNotEmpty
          ? List<String>.from(jsonDecode(tagsJson))
          : [];

      return Cocktail.fromMap(cocktailMap)
        ..ingredients = ingredients
        ..tags = tags;
    }).toList();

    print("Fetched ${cocktails.length} cocktails");
    return cocktails;
  }

  Future<Cocktail?> fetchCocktailById(String id) async {
    print("fetchCocktailById called for ID: $id");

    final db = await instance.database;
    final cocktailMaps = await db.query(
      'cocktails',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (cocktailMaps.isNotEmpty) {
      final cocktailMap = cocktailMaps.first;
      print("Cocktail found with ID: $id");

      final ingredientsJson = cocktailMap['ingredients'] as String?;
      final tagsJson = cocktailMap['tags'] as String?;

      List<Ingredient> ingredients =
          ingredientsJson != null && ingredientsJson.isNotEmpty
              ? (jsonDecode(ingredientsJson) as List)
                  .map((ingredientMap) => Ingredient.fromMap(ingredientMap))
                  .toList()
              : [];

      List<String> tags = tagsJson != null && tagsJson.isNotEmpty
          ? List<String>.from(jsonDecode(tagsJson))
          : [];

      return Cocktail.fromMap(cocktailMap)
        ..ingredients = ingredients
        ..tags = tags;
    } else {
      print("No cocktail found with ID: $id");
      return null;
    }
  }

  Future<int> deleteCocktail(String id) async {
    final db = await instance.database;
    print("Deleting cocktail with ID: $id");
    return await db.delete(
      'cocktails',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
