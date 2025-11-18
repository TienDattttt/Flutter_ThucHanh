import 'package:flutter/material.dart';

class ControlPanel extends StatelessWidget {
  final bool isVisible;
  final int currentPage;
  final int totalPages;
  final VoidCallback onSettingsTap;

  const ControlPanel({
    Key? key,
    required this.isVisible,
    required this.currentPage,
    required this.totalPages,
    required this.onSettingsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: isVisible ? 0 : -100,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page progress
                Semantics(
                  label: 'Trang ${currentPage + 1} trên tổng số $totalPages trang',
                  child: Text(
                    'Trang ${currentPage + 1} / $totalPages',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                // Settings button with minimum touch target
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: onSettingsTap,
                    tooltip: 'Cài đặt',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
