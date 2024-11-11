// lib/models/cocktail.dart

import 'dart:convert';
import 'ingredient.dart';

class Cocktail {
  final String id;
  final String name;
  final String description;
  final String category;
  final String glassType;
  final String instructions;
  List<String> tags;
  final String imageUrl;
  List<Ingredient> ingredients;
  final double rating;

  Cocktail({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.glassType,
    required this.instructions,
    required this.tags,
    required this.imageUrl,
    required this.ingredients,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'glassType': glassType,
      'instructions': instructions,
      'tags': jsonEncode(tags), // Convert tags list to JSON string
      'imageUrl': imageUrl,
      'ingredients': jsonEncode(ingredients.map((i) => i.toMap()).toList()),
      'rating': rating,
    };
  }

  factory Cocktail.fromMap(Map<String, dynamic> map) {
    // Parse tags JSON string, handling null or empty cases
    List<String> parseTags(String? tagsJson) {
      try {
        return tagsJson != null ? List<String>.from(jsonDecode(tagsJson)) : [];
      } catch (e) {
        print("Error parsing tags JSON: $e");
        return [];
      }
    }

    // Parse ingredients JSON string, handling null or empty cases
    List<Ingredient> parseIngredients(String? ingredientsJson) {
      try {
        if (ingredientsJson == null || ingredientsJson.isEmpty) return [];
        final parsedIngredients = jsonDecode(ingredientsJson) as List;
        return parsedIngredients
            .map((item) => Ingredient.fromMap(item))
            .toList();
      } catch (e) {
        print("Error parsing ingredients JSON: $e");
        return [];
      }
    }

    // Debugging: Print parsed ingredients and tags
    List<Ingredient> ingredients =
        parseIngredients(map['ingredients'] as String?);
    print("Parsed ingredients in fromMap: $ingredients");

    return Cocktail(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      glassType: map['glassType'] ?? '',
      instructions: map['instructions'] ?? '',
      tags: parseTags(map['tags'] as String?),
      imageUrl: map['imageUrl'] ?? '',
      ingredients: ingredients,
      rating: (map['rating'] ?? 0.0) as double,
    );
  }
}
