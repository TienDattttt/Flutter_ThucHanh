import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/entities/post.dart';
import '../upload/upload_post_screen.dart';
import 'widgets/post_grid_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postRepo = context.read<PostRepository>();
    final authRepo = context.read<AuthRepository>();

    return Container(
      // Background gradient kiểu Instagram dark
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F2027),
            Color(0xFF203A43),
            Color(0xFF2C5364),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('PhotoShare'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authRepo.signOut(),
            ),
          ],
        ),
        body: StreamBuilder<List<Post>>(
          stream: postRepo.getPostsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final posts = snapshot.data ?? [];
            if (posts.isEmpty) {
              return const Center(
                child: Text(
                  'Chưa có ảnh nào. Hãy đăng tấm đầu tiên!',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: GridView.builder(
                padding: const EdgeInsets.all(4),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return PostGridItem(post: posts[index]);
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_a_photo),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UploadPostScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
