// lib/services/recipe_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class RecipeService {
  final _db = FirebaseFirestore.instance;
  static const _collection = 'recipes';

  Stream<List<Recipe>> getRecipesStream() {
    return _db
        .collection(_collection)
        .orderBy('title')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Recipe.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<List<Recipe>> getRecipesOnce() async {
    final snapshot =
    await _db.collection(_collection).orderBy('title').get();
    return snapshot.docs
        .map((doc) => Recipe.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> addDummyRecipe() async {
    // ví dụ 1 món để seed nhanh
    await _db.collection(_collection).add({
      'title': 'Gà rán mật ong',
      'thumbnailUrl':
      'https://images.pexels.com/photos/4106483/pexels-photo-4106483.jpeg',
      'imageUrl':
      'https://images.pexels.com/photos/4106483/pexels-photo-4106483.jpeg',
      'description': 'Gà rán giòn rụm phủ sốt mật ong chua ngọt kiểu Tasty.',
      'ingredients': [
        '500g thịt gà',
        '2 muỗng canh mật ong',
        '2 muỗng canh nước tương',
        'Tỏi băm, tiêu, muối',
        'Bột bắp/bột chiên giòn',
        'Dầu ăn'
      ],
      'steps': [
        'Ướp gà với gia vị và để 20 phút.',
        'Áo gà qua lớp bột chiên.',
        'Chiên gà vàng giòn.',
        'Làm sốt mật ong trên chảo, cho gà vào đảo đều.',
        'Trang trí với mè rang và hành lá.'
      ],
      'duration': 40,
      'difficulty': 'Trung bình',
    });
  }
}
