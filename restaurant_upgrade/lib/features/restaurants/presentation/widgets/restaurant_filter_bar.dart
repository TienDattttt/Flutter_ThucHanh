import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/restaurant_bloc.dart';
import '../bloc/restaurant_event.dart';
import '../bloc/restaurant_state.dart';

class RestaurantFilterBar extends StatefulWidget {
  final String? selectedCategory;
  final double? selectedMinRating;
  final Function({String? category, double? minRating}) onFilterChanged;

  const RestaurantFilterBar({
    super.key,
    this.selectedCategory,
    this.selectedMinRating,
    required this.onFilterChanged,
  });

  @override
  State<RestaurantFilterBar> createState() => _RestaurantFilterBarState();
}

class _RestaurantFilterBarState extends State<RestaurantFilterBar> {
  List<String> _categories = [];
  bool _categoriesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    context.read<RestaurantBloc>().add(const RestaurantCategoriesLoadRequested());
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildCategoryFilterSheet(),
    );
  }

  void _showRatingFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildRatingFilterSheet(),
    );
  }

  Widget _buildCategoryFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Chọn danh mục',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // All categories option
          ListTile(
            title: const Text('Tất cả danh mục'),
            leading: Radio<String?>(
              value: null,
              groupValue: widget.selectedCategory,
              onChanged: (value) {
                widget.onFilterChanged(category: null, minRating: widget.selectedMinRating);
                Navigator.pop(context);
              },
            ),
          ),
          
          // Category options
          ..._categories.map((category) {
            return ListTile(
              title: Text(category),
              leading: Radio<String?>(
                value: category,
                groupValue: widget.selectedCategory,
                onChanged: (value) {
                  widget.onFilterChanged(category: value, minRating: widget.selectedMinRating);
                  Navigator.pop(context);
                },
              ),
            );
          }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingFilterSheet() {
    final ratingOptions = [
      {'value': null, 'label': 'Tất cả đánh giá'},
      {'value': 4.0, 'label': '4+ sao'},
      {'value': 3.0, 'label': '3+ sao'},
      {'value': 2.0, 'label': '2+ sao'},
      {'value': 1.0, 'label': '1+ sao'},
    ];

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn đánh giá tối thiểu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          ...ratingOptions.map((option) {
            return ListTile(
              title: Text(option['label'] as String),
              leading: Radio<double?>(
                value: option['value'] as double?,
                groupValue: widget.selectedMinRating,
                onChanged: (value) {
                  widget.onFilterChanged(category: widget.selectedCategory, minRating: value);
                  Navigator.pop(context);
                },
              ),
              trailing: option['value'] != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          size: 16,
                          color: index < (option['value'] as double)
                              ? Colors.amber
                              : Colors.grey[300],
                        );
                      }),
                    )
                  : null,
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RestaurantBloc, RestaurantState>(
      listener: (context, state) {
        if (state is RestaurantCategoriesLoaded && !_categoriesLoaded) {
          setState(() {
            _categories = state.categories;
            _categoriesLoaded = true;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        child: Row(
          children: [
            // Category Filter
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showCategoryFilter,
                icon: const Icon(Icons.category, size: 18),
                label: Text(
                  widget.selectedCategory ?? 'Danh mục',
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: widget.selectedCategory != null
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                ),
              ),
            ),
            
            const SizedBox(width: AppConstants.smallPadding),
            
            // Rating Filter
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showRatingFilter,
                icon: const Icon(Icons.star, size: 18),
                label: Text(
                  widget.selectedMinRating != null
                      ? '${widget.selectedMinRating!.toInt()}+ sao'
                      : 'Đánh giá',
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: widget.selectedMinRating != null
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                ),
              ),
            ),
            
            // Clear Filters
            if (widget.selectedCategory != null || widget.selectedMinRating != null) ...[
              const SizedBox(width: AppConstants.smallPadding),
              IconButton(
                onPressed: () {
                  widget.onFilterChanged(category: null, minRating: null);
                },
                icon: const Icon(Icons.clear),
                tooltip: 'Xóa bộ lọc',
              ),
            ],
          ],
        ),
      ),
    );
  }
}