import 'package:flutter/material.dart';

class AnimatedSettingsPanel extends StatelessWidget {
  final bool isDarkMode;
  final double fontSize;
  final Function(bool) onThemeToggle;
  final Function(double) onFontSizeChange;

  const AnimatedSettingsPanel({
    Key? key,
    required this.isDarkMode,
    required this.fontSize,
    required this.onThemeToggle,
    required this.onFontSizeChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cài đặt',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Dark mode toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Chế độ tối',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Switch(
                  value: isDarkMode,
                  onChanged: onThemeToggle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Font size selector
          Text(
            'Kích thước chữ',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _FontSizeButton(
                label: 'Nhỏ',
                fontSize: 14.0,
                isSelected: fontSize == 14.0,
                onTap: () => onFontSizeChange(14.0),
              ),
              _FontSizeButton(
                label: 'Trung bình',
                fontSize: 18.0,
                isSelected: fontSize == 18.0,
                onTap: () => onFontSizeChange(18.0),
              ),
              _FontSizeButton(
                label: 'Lớn',
                fontSize: 22.0,
                isSelected: fontSize == 22.0,
                onTap: () => onFontSizeChange(22.0),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Preview text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: fontSize,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              child: const Text(
                'Đây là văn bản mẫu để xem trước kích thước chữ.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FontSizeButton extends StatelessWidget {
  final String label;
  final double fontSize;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontSizeButton({
    required this.label,
    required this.fontSize,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
