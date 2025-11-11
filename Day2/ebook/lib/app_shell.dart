import 'package:ebook/screens/home/home_screen.dart';
import 'package:ebook/screens/settings/settings_screen.dart';
import 'package:flutter/cupertino.dart'; // Dùng icon của Apple
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với BottomNav
  final List<Widget> _screens = [
    const HomeScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book_fill), // Icon Thư viện
            label: 'Thư viện',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings), // Icon Cài đặt
            label: 'Cài đặt',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}