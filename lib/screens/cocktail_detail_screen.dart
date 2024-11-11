import 'package:flutter/material.dart';
import '../models/cocktail.dart';
import '../database/db_helper.dart';
import 'add_cocktail_screen.dart';
import 'dart:io';

class CocktailDetailScreen extends StatelessWidget {
  final Cocktail cocktail;

  const CocktailDetailScreen({Key? key, required this.cocktail})
      : super(key: key);

  Future<void> _deleteCocktail(BuildContext context) async {
    final dbHelper = DBHelper.instance;

    final bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Cocktail"),
          content: const Text("Are you sure you want to delete this cocktail?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await dbHelper.deleteCocktail(cocktail.id);
      Navigator.of(context).pop();
    }
  }

  void _editCocktail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddCocktailScreen(cocktail: cocktail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(cocktail.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editCocktail(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteCocktail(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rounded corners and shadow
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 6),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.hardEdge,
                child: cocktail.imageUrl.isNotEmpty &&
                        File(cocktail.imageUrl).existsSync()
                    ? Image.file(
                        File(cocktail.imageUrl),
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/cocktail.jpg',
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cocktail.name,
                    style: Theme.of(context).textTheme.headline4?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.category, color: Colors.grey[400], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Category: ${cocktail.category}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_bar, color: Colors.grey[400], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Glass Type: ${cocktail.glassType}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Instructions:",
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cocktail.instructions,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: Colors.grey[300],
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Ingredients:",
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  ...cocktail.ingredients.map((ingredient) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          '${ingredient.quantity} ${ingredient.unit} ${ingredient.name}',
                          style:
                              Theme.of(context).textTheme.bodyText1?.copyWith(
                                    color: Colors.grey[300],
                                  ),
                        ),
                      )),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
