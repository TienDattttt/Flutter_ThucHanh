import 'package:flutter/material.dart';
import '../../../domain/entities/post.dart';

class PostGridItem extends StatelessWidget {
  final Post post;

  const PostGridItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: mở màn chi tiết nếu muốn
      },
      child: Hero(
        tag: post.id,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(post.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
