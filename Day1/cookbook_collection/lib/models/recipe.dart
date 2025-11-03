// lib/models/recipe.dart
class Recipe {
  final String id;
  final String title;
  final String thumbnail;
  final String image;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final int duration; // phút
  final String difficulty; // dễ / trung bình / khó

  Recipe({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.image,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.duration,
    required this.difficulty,
  });

  // Dùng với Firestore
  factory Recipe.fromMap(String id, Map<String, dynamic> data) {
    return Recipe(
      id: id,
      title: data['title'] ?? '',
      thumbnail: data['thumbnail'] ?? '',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      duration: (data['duration'] ?? 0) as int,
      difficulty: data['difficulty'] ?? 'Dễ',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'thumbnail': thumbnail,
      'image': image,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'duration': duration,
      'difficulty': difficulty,
    };
  }
}
