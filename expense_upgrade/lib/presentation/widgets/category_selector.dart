import 'package:flutter/material.dart';
import '../../domain/entities/expense_category.dart';

class CategorySelector extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onCategorySelected;
  final bool isLoading;
  
  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh mục',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (categories.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Không có danh mục nào'),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedCategoryId == null
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category.id == selectedCategoryId;
                
                return GestureDetector(
                  onTap: () => onCategorySelected(category.id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category.color.withOpacity(0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? category.color
                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? category.color : null,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        
        if (selectedCategoryId == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Vui lòng chọn danh mục',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}