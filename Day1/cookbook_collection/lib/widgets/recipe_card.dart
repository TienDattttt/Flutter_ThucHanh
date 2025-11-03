import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../screens/recipe_detail_screen.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, animation, __) => FadeTransition(
              opacity: animation,
              child: RecipeDetailScreen(recipe: recipe),
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Ảnh + Hero
            Hero(
              tag: 'recipe-${recipe.id}',
              child: Material(
                type: MaterialType.transparency, // <- thêm Material bọc Ink
                child: Ink.image(
                  image: AssetImage(recipe.thumbnail),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Overlay gradient tối để chữ nổi
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.75),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Tên món + thời gian
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      recipe.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, size: 16),
                        const SizedBox(width: 4),
                        Text('${recipe.duration}\''),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Badge độ khó
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  recipe.difficulty,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
