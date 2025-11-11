import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';

class RestaurantRemoteDataSource {
  final _db = FirebaseFirestore.instance;

  /// Lắng nghe danh sách nhà hàng realtime từ Firestore
  Stream<List<RestaurantModel>> watchRestaurants() {
    return _db.collection('restaurants').orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => RestaurantModel.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  /// Lấy chi tiết 1 nhà hàng theo ID
  Future<RestaurantModel> getById(String id) async {
    final doc = await _db.collection('restaurants').doc(id).get();
    if (!doc.exists) throw Exception('Không tìm thấy nhà hàng');
    return RestaurantModel.fromMap(doc.id, doc.data()!);
  }
}
