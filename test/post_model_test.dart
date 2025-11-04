import 'package:flutter_test/flutter_test.dart';
import 'package:photo_sharing/data/models/post_model.dart';


void main() {
  test('PostModel fromMap & toMap hoạt động đúng', () {
    final now = DateTime.now();
    final map = {
      'imageUrl': 'http://example.com/img.jpg',
      'caption': 'Hello',
      'userId': 'uid123',
      'userEmail': 'test@example.com',
      'createdAt': now,
      'likes': 5,
    };

    final model = PostModel.fromMap('id123', map);
    expect(model.id, 'id123');
    expect(model.imageUrl, map['imageUrl']);
    expect(model.likes, 5);

    final back = model.toMap();
    expect(back['caption'], 'Hello');
    expect(back['userId'], 'uid123');
  });
}
