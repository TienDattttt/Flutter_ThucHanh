import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/app_constants.dart';

class DescriptionInput extends StatefulWidget {
  final TextEditingController controller;
  
  const DescriptionInput({
    super.key,
    required this.controller,
  });

  @override
  State<DescriptionInput> createState() => _DescriptionInputState();
}

class _DescriptionInputState extends State<DescriptionInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mô tả',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
          maxLength: AppConstants.maxDescriptionLength,
          decoration: InputDecoration(
            hintText: 'Nhập mô tả cho giao dịch...',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.description_outlined),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            counterText: '${widget.controller.text.length}/${AppConstants.maxDescriptionLength}',
          ),
          validator: Validators.validateDescription,
          onChanged: (value) {
            setState(() {}); // Rebuild to update counter
          },
        ),
        
        // Quick description suggestions
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _getQuickSuggestions()
              .map((suggestion) => _buildSuggestionChip(suggestion))
              .toList(),
        ),
      ],
    );
  }
  
  List<String> _getQuickSuggestions() {
    return [
      'Ăn sáng',
      'Ăn trưa',
      'Ăn tối',
      'Cà phê',
      'Xăng xe',
      'Grab/Taxi',
      'Siêu thị',
      'Thuốc',
      'Phim',
      'Mua sắm',
    ];
  }
  
  Widget _buildSuggestionChip(String suggestion) {
    return ActionChip(
      label: Text(
        suggestion,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onPressed: () {
        widget.controller.text = suggestion;
        setState(() {});
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}