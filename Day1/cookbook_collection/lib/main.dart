import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/recipes_list_screen.dart';

void main() {
  runApp(const CookbookApp());
}

class CookbookApp extends StatelessWidget {
  const CookbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cookbook Collection',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RecipesListScreen(),
    );
  }
}
