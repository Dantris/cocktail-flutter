// lib/screens/cocktail_list_screen.dart
import 'package:flutter/material.dart';
import '../models/cocktail.dart';
import '../database/db_helper.dart';
import 'cocktail_detail_screen.dart';

class CocktailListScreen extends StatefulWidget {
  const CocktailListScreen({Key? key}) : super(key: key);

  @override
  _CocktailListScreenState createState() => _CocktailListScreenState();
}

class _CocktailListScreenState extends State<CocktailListScreen> {
  List<Cocktail> cocktails = [];

  @override
  void initState() {
    super.initState();
    _loadCocktails();
  }

  Future<void> _loadCocktails() async {
    final data = await DBHelper.instance.fetchAllCocktails();
    setState(() {
      cocktails = data;
      cocktails.sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cocktails"),
      ),
      body: cocktails.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: cocktails.length,
              itemBuilder: (context, index) {
                final cocktail = cocktails[index];
                final firstLetter = cocktail.name[0].toUpperCase();
                final isFirstInSection = index == 0 ||
                    cocktail.name[0].toUpperCase() !=
                        cocktails[index - 1].name[0].toUpperCase();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFirstInSection)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          firstLetter,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: Colors.grey),
                        ),
                      ),
                    ListTile(
                      title: Text(cocktail.name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CocktailDetailScreen(cocktail: cocktail),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
}
