import 'package:flutter/material.dart';
import 'dart:io';
import '../models/cocktail.dart';
import '../models/ingredient.dart';
import '../database/db_helper.dart';
import '../services/images_services.dart';

class AddCocktailScreen extends StatefulWidget {
  final Cocktail? cocktail;

  const AddCocktailScreen({Key? key, this.cocktail}) : super(key: key);

  @override
  _AddCocktailScreenState createState() => _AddCocktailScreenState();
}

class _AddCocktailScreenState extends State<AddCocktailScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImageService _imageService = ImageService();

  // Form field values
  String _name = '';
  String _description = '';
  String _category = '';
  String _glassType = '';
  String _instructions = '';
  String _imageUrl = '';
  List<Ingredient> _ingredients = [];

  // Controllers for ingredient inputs
  final _ingredientNameController = TextEditingController();
  final _ingredientQuantityController = TextEditingController();
  final _ingredientUnitController = TextEditingController();

  // List of common glass types
  final List<String> _glassTypes = [
    "Martini",
    "Highball",
    "Old Fashioned",
    "Collins",
    "Coupe",
    "Rocks",
    "Margarita",
    "Wine",
    "Flute",
    "Pint",
    "Shot",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.cocktail != null) {
      _name = widget.cocktail!.name;
      _description = widget.cocktail!.description;
      _category = widget.cocktail!.category;
      _glassType = widget.cocktail!.glassType;
      _instructions = widget.cocktail!.instructions;
      _imageUrl = widget.cocktail!.imageUrl;
      _ingredients = widget.cocktail!.ingredients;
    }
  }

  void _addIngredient() {
    final name = _ingredientNameController.text.trim();
    final quantity = _ingredientQuantityController.text.trim();
    final unit = _ingredientUnitController.text.trim();

    if (name.isNotEmpty && quantity.isNotEmpty) {
      setState(() {
        _ingredients
            .add(Ingredient(name: name, quantity: quantity, unit: unit));
        _ingredientNameController.clear();
        _ingredientQuantityController.clear();
        _ingredientUnitController.clear();
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final path = await _imageService.captureImage();
      setState(() {
        _imageUrl = path;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to capture image: ${e.toString()}")),
      );
    }
  }

  Future<void> _saveCocktail() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final cocktailToSave = Cocktail(
        id: widget.cocktail?.id ?? DateTime.now().toString(),
        name: _name,
        description: _description,
        category: _category,
        glassType: _glassType,
        instructions: _instructions,
        tags: [],
        imageUrl: _imageUrl,
        ingredients: _ingredients,
        rating: 0.0,
      );

      if (widget.cocktail == null) {
        await DBHelper.instance.insertCocktail(cocktailToSave);
      } else {
        await DBHelper.instance.updateCocktail(cocktailToSave);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.cocktail == null ? "Add New Cocktail" : "Edit Cocktail"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: "Name"),
                onSaved: (value) => _name = value ?? '',
                validator: (value) => value!.isEmpty ? "Enter a name" : null,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: "Description"),
                onSaved: (value) => _description = value ?? '',
              ),
              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: "Category"),
                onSaved: (value) => _category = value ?? '',
              ),
              DropdownButtonFormField<String>(
                value: _glassType.isNotEmpty ? _glassType : null,
                decoration: const InputDecoration(labelText: "Glass Type"),
                items: _glassTypes.map((String glassType) {
                  return DropdownMenuItem<String>(
                    value: glassType,
                    child: Text(glassType),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _glassType = value ?? '';
                  });
                },
                onSaved: (value) => _glassType = value ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? "Please select a glass type"
                    : null,
              ),
              TextFormField(
                initialValue: _instructions,
                decoration: const InputDecoration(labelText: "Instructions"),
                onSaved: (value) => _instructions = value ?? '',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text("Ingredients", style: Theme.of(context).textTheme.headline6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ingredientNameController,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _ingredientQuantityController,
                      decoration: const InputDecoration(labelText: "Quantity"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _ingredientUnitController,
                      decoration: const InputDecoration(labelText: "Unit"),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addIngredient,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_ingredients.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _ingredients.map((ingredient) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                          '${ingredient.quantity} ${ingredient.unit} ${ingredient.name}'),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              if (_imageUrl.isNotEmpty)
                Image.file(File(_imageUrl),
                    width: double.infinity, height: 200),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Pick Image"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveCocktail,
                child: const Text("Save Cocktail"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
