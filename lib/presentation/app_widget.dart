import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../data/datasources/firebase_auth_datasource.dart';
import '../data/datasources/firebase_post_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/post_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/post_repository.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🔐 Auth provider
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(
            FirebaseAuthDataSource(FirebaseAuth.instance),
          ),
        ),

        // 📸 Post provider (dùng Cloudinary + Firestore, không dùng Firebase Storage nữa)
        Provider<PostRepository>(
          create: (_) => PostRepositoryImpl(
            FirebasePostDataSource(
              FirebaseFirestore.instance,
              FirebaseAuth.instance, // truyền thêm FirebaseAuth nếu cần user info
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Photo Share',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _RootAuthListener(),
      ),
    );
  }
}

class _RootAuthListener extends StatelessWidget {
  const _RootAuthListener();

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthRepository>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authRepo.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == null) {
          return const LoginScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
