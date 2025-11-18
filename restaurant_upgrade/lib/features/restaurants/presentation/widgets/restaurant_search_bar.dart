import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class RestaurantSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String? hintText;
  final String? initialValue;

  const RestaurantSearchBar({
    super.key,
    required this.onSearch,
    this.hintText,
    this.initialValue,
  });

  @override
  State<RestaurantSearchBar> createState() => _RestaurantSearchBarState();
}

class _RestaurantSearchBarState extends State<RestaurantSearchBar> {
  late TextEditingController _controller;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _isSearching = value.isNotEmpty;
    });

    // Debounce search
    Future.delayed(const Duration(milliseconds: AppConstants.debounceDelay), () {
      if (_controller.text == value) {
        widget.onSearch(value);
      }
    });
  }

  void _onClearSearch() {
    _controller.clear();
    setState(() {
      _isSearching = false;
    });
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Tìm kiếm...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _onClearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}