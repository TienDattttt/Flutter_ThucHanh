import 'package:ebook/app_shell.dart';
import 'package:ebook/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // Dùng ChangeNotifierProvider để cung cấp ThemeProvider cho toàn app
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi theme từ provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Ebook Reader',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode, // Dùng themeMode từ provider
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AppShell(), // Bắt đầu với AppShell
    );
  }
}