import 'package:flutter/material.dart';
import '../widgets/recipe_card.dart';
import '../data/recipes_data.dart';

class RecipesListScreen extends StatelessWidget {
  const RecipesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Gradient nền kiểu Tasty
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF9A9E),
            Color(0xFFFAD0C4),
            Color(0xFFFBC2EB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Công thức Nấu ăn'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: demoRecipes.length,
          itemBuilder: (context, index) {
            return RecipeCard(recipe: demoRecipes[index]);
          },
        ),
      ),
    );
  }
}
