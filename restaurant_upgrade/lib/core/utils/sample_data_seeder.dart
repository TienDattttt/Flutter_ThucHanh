import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

class SampleDataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed sample restaurants data
  static Future<void> seedRestaurants() async {
    try {
      final restaurants = [
        {
          'name': 'Phở Hà Nội',
          'description': 'Phở bò truyền thống Hà Nội với nước dùng đậm đà, thịt bò tươi ngon',
          'address': '123 Nguyễn Huệ, Quận 1, TP.HCM',
          'phone': '0901234567',
          'email': 'phohanoi@gmail.com',
          'website': 'https://phohanoi.com',
          'categories': ['Món Việt', 'Phở'],
          'priceRange': 'budget',
          'location': {
            'latitude': 10.7769,
            'longitude': 106.7009,
          },
          'imageUrls': [
            'https://images.unsplash.com/photo-1555126634-323283e090fa?w=800',
            'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=800',
          ],
          'openingHours': {
            'monday': {'open': '06:00', 'close': '22:00'},
            'tuesday': {'open': '06:00', 'close': '22:00'},
            'wednesday': {'open': '06:00', 'close': '22:00'},
            'thursday': {'open': '06:00', 'close': '22:00'},
            'friday': {'open': '06:00', 'close': '22:00'},
            'saturday': {'open': '06:00', 'close': '23:00'},
            'sunday': {'open': '06:00', 'close': '23:00'},
          },
          'averageRating': 4.5,
          'totalReviews': 128,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Bún Bò Huế Cô Ba',
          'description': 'Bún bò Huế chuẩn vị xứ Huế, nước dùng cay nồng đặc trưng',
          'address': '456 Lê Lợi, Quận 3, TP.HCM',
          'phone': '0902345678',
          'email': 'bunbohue@gmail.com',
          'website': null,
          'categories': ['Món Việt', 'Bún'],
          'priceRange': 'budget',
          'location': {
            'latitude': 10.7756,
            'longitude': 106.6934,
          },
          'imageUrls': [
            'https://images.unsplash.com/photo-1559847844-d721426d6edc?w=800',
          ],
          'openingHours': {
            'monday': {'open': '07:00', 'close': '21:00'},
            'tuesday': {'open': '07:00', 'close': '21:00'},
            'wednesday': {'open': '07:00', 'close': '21:00'},
            'thursday': {'open': '07:00', 'close': '21:00'},
            'friday': {'open': '07:00', 'close': '21:00'},
            'saturday': {'open': '07:00', 'close': '22:00'},
            'sunday': {'open': '07:00', 'close': '22:00'},
          },
          'averageRating': 4.2,
          'totalReviews': 89,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Pizza 4P\'s',
          'description': 'Pizza phong cách Nhật Bản với nguyên liệu tươi ngon, phô mai mozzarella tự làm',
          'address': '8/15 Lê Thị Riêng, Quận 1, TP.HCM',
          'phone': '0903456789',
          'email': 'info@pizza4ps.com',
          'website': 'https://pizza4ps.com',
          'categories': ['Pizza', 'Món Âu'],
          'priceRange': 'mid-range',
          'location': {
            'latitude': 10.7829,
            'longitude': 106.6973,
          },
          'imageUrls': [
            'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800',
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800',
          ],
          'openingHours': {
            'monday': {'open': '11:00', 'close': '22:00'},
            'tuesday': {'open': '11:00', 'close': '22:00'},
            'wednesday': {'open': '11:00', 'close': '22:00'},
            'thursday': {'open': '11:00', 'close': '22:00'},
            'friday': {'open': '11:00', 'close': '23:00'},
            'saturday': {'open': '11:00', 'close': '23:00'},
            'sunday': {'open': '11:00', 'close': '22:00'},
          },
          'averageRating': 4.7,
          'totalReviews': 256,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Quán Ăn Ngon',
          'description': 'Buffet các món ăn truyền thống Việt Nam trong không gian sân vườn',
          'address': '138 Nam Kỳ Khởi Nghĩa, Quận 3, TP.HCM',
          'phone': '0904567890',
          'email': 'quanangon@gmail.com',
          'website': 'https://quanangon.com.vn',
          'categories': ['Món Việt', 'Buffet'],
          'priceRange': 'mid-range',
          'location': {
            'latitude': 10.7784,
            'longitude': 106.6917,
          },
          'imageUrls': [
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
          ],
          'openingHours': {
            'monday': {'open': '10:00', 'close': '22:00'},
            'tuesday': {'open': '10:00', 'close': '22:00'},
            'wednesday': {'open': '10:00', 'close': '22:00'},
            'thursday': {'open': '10:00', 'close': '22:00'},
            'friday': {'open': '10:00', 'close': '22:30'},
            'saturday': {'open': '10:00', 'close': '22:30'},
            'sunday': {'open': '10:00', 'close': '22:00'},
          },
          'averageRating': 4.3,
          'totalReviews': 342,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Highlands Coffee',
          'description': 'Chuỗi cà phê Việt Nam với không gian hiện đại, thức uống đa dạng',
          'address': '54 Nguyễn Du, Quận 1, TP.HCM',
          'phone': '0905678901',
          'email': 'info@highlandscoffee.com.vn',
          'website': 'https://highlandscoffee.com.vn',
          'categories': ['Cafe', 'Tráng miệng'],
          'priceRange': 'budget',
          'location': {
            'latitude': 10.7747,
            'longitude': 106.6958,
          },
          'imageUrls': [
            'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800',
          ],
          'openingHours': {
            'monday': {'open': '06:30', 'close': '22:00'},
            'tuesday': {'open': '06:30', 'close': '22:00'},
            'wednesday': {'open': '06:30', 'close': '22:00'},
            'thursday': {'open': '06:30', 'close': '22:00'},
            'friday': {'open': '06:30', 'close': '23:00'},
            'saturday': {'open': '06:30', 'close': '23:00'},
            'sunday': {'open': '07:00', 'close': '22:00'},
          },
          'averageRating': 4.1,
          'totalReviews': 167,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      final batch = _firestore.batch();
      
      for (final restaurant in restaurants) {
        final docRef = _firestore.collection(AppConstants.restaurantsCollection).doc();
        batch.set(docRef, restaurant);
      }

      await batch.commit();
      print('✅ Successfully seeded ${restaurants.length} restaurants');
    } catch (e) {
      print('❌ Error seeding restaurants: $e');
      rethrow;
    }
  }

  /// Seed sample categories
  static Future<void> seedCategories() async {
    try {
      final categories = AppConstants.defaultCategories.map((category) => {
        'name': category,
        'description': 'Danh mục $category',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      }).toList();

      final batch = _firestore.batch();
      
      for (final category in categories) {
        final docRef = _firestore.collection(AppConstants.categoriesCollection).doc();
        batch.set(docRef, category);
      }

      await batch.commit();
      print('✅ Successfully seeded ${categories.length} categories');
    } catch (e) {
      print('❌ Error seeding categories: $e');
      rethrow;
    }
  }

  /// Seed all sample data
  static Future<void> seedAll() async {
    try {
      print('🌱 Starting to seed sample data...');
      
      await seedCategories();
      await seedRestaurants();
      
      print('🎉 All sample data seeded successfully!');
    } catch (e) {
      print('❌ Error seeding sample data: $e');
      rethrow;
    }
  }

  /// Clear all data (for testing purposes)
  static Future<void> clearAll() async {
    try {
      print('🗑️ Clearing all data...');
      
      // Clear restaurants
      final restaurantsSnapshot = await _firestore
          .collection(AppConstants.restaurantsCollection)
          .get();
      
      final batch1 = _firestore.batch();
      for (final doc in restaurantsSnapshot.docs) {
        batch1.delete(doc.reference);
      }
      await batch1.commit();
      
      // Clear categories
      final categoriesSnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .get();
      
      final batch2 = _firestore.batch();
      for (final doc in categoriesSnapshot.docs) {
        batch2.delete(doc.reference);
      }
      await batch2.commit();
      
      print('✅ All data cleared successfully!');
    } catch (e) {
      print('❌ Error clearing data: $e');
      rethrow;
    }
  }
}