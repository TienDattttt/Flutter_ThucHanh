import 'package:flutter/material.dart';

class EnhancedSettingsPanel extends StatelessWidget {
  final bool isDarkMode;
  final double fontSize;
  final double lineHeight;
  final String fontFamily;
  final Color backgroundColor;
  final Function(bool) onThemeToggle;
  final Function(double) onFontSizeChange;
  final Function(double) onLineHeightChange;
  final Function(String) onFontFamilyChange;
  final Function(Color) onBackgroundColorChange;

  const EnhancedSettingsPanel({
    Key? key,
    required this.isDarkMode,
    required this.fontSize,
    required this.lineHeight,
    required this.fontFamily,
    required this.backgroundColor,
    required this.onThemeToggle,
    required this.onFontSizeChange,
    required this.onLineHeightChange,
    required this.onFontFamilyChange,
    required this.onBackgroundColorChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Tùy chỉnh đọc sách',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Settings content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Theme section
                _buildSectionTitle(context, 'Giao diện', Icons.palette_outlined),
                const SizedBox(height: 12),
                _buildThemeSelector(context),
                const SizedBox(height: 24),

                // Font size section
                _buildSectionTitle(context, 'Kích thước chữ', Icons.format_size),
                const SizedBox(height: 12),
                _buildFontSizeSlider(context),
                const SizedBox(height: 24),

                // Line height section
                _buildSectionTitle(context, 'Khoảng cách dòng', Icons.format_line_spacing),
                const SizedBox(height: 12),
                _buildLineHeightSlider(context),
                const SizedBox(height: 24),

                // Font family section
                _buildSectionTitle(context, 'Phông chữ', Icons.font_download_outlined),
                const SizedBox(height: 12),
                _buildFontFamilySelector(context),
                const SizedBox(height: 24),

                // Background color section
                _buildSectionTitle(context, 'Màu nền', Icons.color_lens_outlined),
                const SizedBox(height: 12),
                _buildBackgroundColorSelector(context),
                const SizedBox(height: 24),

                // Preview section
                _buildSectionTitle(context, 'Xem trước', Icons.visibility_outlined),
                const SizedBox(height: 12),
                _buildPreview(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildThemeOption(
            context,
            'Sáng',
            Icons.light_mode,
            !isDarkMode,
            () => onThemeToggle(false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildThemeOption(
            context,
            'Tối',
            Icons.dark_mode,
            isDarkMode,
            () => onThemeToggle(true),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('A', style: TextStyle(fontSize: 14)),
            Expanded(
              child: Slider(
                value: fontSize,
                min: 12.0,
                max: 28.0,
                divisions: 16,
                label: fontSize.round().toString(),
                onChanged: onFontSizeChange,
              ),
            ),
            const Text('A', style: TextStyle(fontSize: 24)),
          ],
        ),
        Text(
          '${fontSize.round()}px',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildLineHeightSlider(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: lineHeight,
          min: 1.0,
          max: 2.5,
          divisions: 15,
          label: lineHeight.toStringAsFixed(1),
          onChanged: onLineHeightChange,
        ),
        Text(
          '${lineHeight.toStringAsFixed(1)}x',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildFontFamilySelector(BuildContext context) {
    final fonts = [
      {'name': 'Mặc định', 'value': 'default'},
      {'name': 'Serif', 'value': 'serif'},
      {'name': 'Sans Serif', 'value': 'sans'},
      {'name': 'Monospace', 'value': 'mono'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: fonts.map((font) {
        final isSelected = fontFamily == font['value'];
        return ChoiceChip(
          label: Text(font['name']!),
          selected: isSelected,
          onSelected: (_) => onFontFamilyChange(font['value']!),
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBackgroundColorSelector(BuildContext context) {
    final colors = [
      {'name': 'Trắng', 'color': Colors.white},
      {'name': 'Kem', 'color': const Color(0xFFFFF8E1)},
      {'name': 'Xanh nhạt', 'color': const Color(0xFFE3F2FD)},
      {'name': 'Xám', 'color': const Color(0xFFF5F5F5)},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((colorData) {
        final color = colorData['color'] as Color;
        final isSelected = backgroundColor.value == color.value;
        return InkWell(
          onTap: () => onBackgroundColorChange(color),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Text(
        'Đây là văn bản mẫu để xem trước các cài đặt của bạn. Bạn có thể điều chỉnh kích thước chữ, khoảng cách dòng, phông chữ và màu nền để có trải nghiệm đọc tốt nhất.',
        style: TextStyle(
          fontSize: fontSize,
          height: lineHeight,
          fontFamily: _getFontFamily(),
          color: Colors.black87,
        ),
      ),
    );
  }

  String? _getFontFamily() {
    switch (fontFamily) {
      case 'serif':
        return 'serif';
      case 'sans':
        return 'sans-serif';
      case 'mono':
        return 'monospace';
      default:
        return null;
    }
  }
}
