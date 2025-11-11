import 'package:ebook/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Chế độ Tối'),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (bool value) {
              // Gọi hàm toggleTheme khi switch
              themeProvider.toggleTheme(value);
            },
          ),
          // Bạn có thể thêm các cài đặt khác ở đây (font-size, v.v.)
          // và lưu chúng bằng SharedPreferences
        ],
      ),
    );
  }
}