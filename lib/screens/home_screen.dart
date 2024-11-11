import 'package:flutter/material.dart';
import 'dart:io'; // Import added here

import '../models/cocktail.dart';
import '../database/db_helper.dart';
import 'cocktail_detail_screen.dart';
import 'add_cocktail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Cocktail> _recentCocktails = [];
  Cocktail? _featuredCocktail;

  @override
  void initState() {
    super.initState();
    _loadCocktails();
  }

  Future<void> _loadCocktails() async {
    final allCocktails = await DBHelper.instance.fetchAllCocktails();
    setState(() {
      _recentCocktails = allCocktails.reversed.take(5).toList(); // Last 5 added
      _featuredCocktail = (allCocktails..shuffle()).first; // Random featured
    });
  }

  void _openCocktailDetail(Cocktail cocktail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CocktailDetailScreen(cocktail: cocktail),
      ),
    );
  }

  void _addNewCocktail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCocktailScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liquid Library"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Cocktail Section
            if (_featuredCocktail != null)
              GestureDetector(
                onTap: () => _openCocktailDetail(_featuredCocktail!),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.file(
                          File(_featuredCocktail!.imageUrl),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _featuredCocktail!.name,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Featured Cocktail of the Day",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Search Bar
            TextField(
              decoration: InputDecoration(
                labelText: "Search Cocktails",
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (query) {
                // Implement search functionality if needed
              },
            ),
            const SizedBox(height: 20),
            // Categories Section
            Text("Categories", style: Theme.of(context).textTheme.headline6),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CategoryIcon("Classics", Icons.local_bar),
                CategoryIcon("Summer", Icons.wb_sunny),
                CategoryIcon("Non-Alcoholic", Icons.no_drinks),
              ],
            ),
            const SizedBox(height: 20),
            // Recently Added Section
            if (_recentCocktails.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Recently Added",
                      style: Theme.of(context).textTheme.headline6),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _recentCocktails.map((cocktail) {
                        return GestureDetector(
                          onTap: () => _openCocktailDetail(cocktail),
                          child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              width: 150,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(8)),
                                    child: Image.file(
                                      File(cocktail.imageUrl),
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      cocktail.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // Add New Cocktail Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _addNewCocktail,
                icon: Icon(Icons.add),
                label: Text("Add New Cocktail"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  final String label;
  final IconData icon;

  const CategoryIcon(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: Colors.grey[700]),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
