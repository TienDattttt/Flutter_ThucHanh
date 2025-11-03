import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_sharing/domain/entities/post.dart';
import 'package:photo_sharing/presentation/home/widgets/post_grid_item.dart';


void main() {
  testWidgets('PostGridItem hiển thị ảnh', (tester) async {
    final post = Post(
      id: 'p1',
      imageUrl: 'http://example.com/img.jpg',
      caption: 'Test',
      userId: 'u1',
      userEmail: 'test@example.com',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostGridItem(post: post),
        ),
      ),
    );

    // Kiểm tra có NetworkImage
    final networkImageFinder = find.byType(Image);
    expect(networkImageFinder, findsOneWidget);
  });
}
