import 'package:expense_wise/core/app_colors.dart';
import 'package:expense_wise/core/helper/category_helper.dart';
import 'package:expense_wise/data/enums/expense_category_enum.dart';
import 'package:expense_wise/presentation/viewmodel/home_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  Set<ExpenseCategory> tempSelectedCategories = {};

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timestamp){
      tempSelectedCategories = Set.from(ref.read(homeScreenViewModelProvider).selectedCategories);
      setState(() {

      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter by Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // --- UPDATED CLEAR BUTTON ---
              if (tempSelectedCategories.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      tempSelectedCategories.clear();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ExpenseCategory.values.map((category) {
              final isSelected = tempSelectedCategories.contains(category);
              // Get the icon for this category
              final catIcon = CategoryHelper.getIcon(category);

              return FilterChip(
                // --- ADDED AVATAR (ICON) ---
                avatar: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(
                      catIcon,
                      size: 18,
                      color: isSelected ? AppColors.primaryRed : Colors.grey.shade600
                  ),
                ),
                label: Text(category.toCategoryProper()),
                selected: isSelected,
                selectedColor: AppColors.primaryRed.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primaryRed : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                showCheckmark: false,
                checkmarkColor: AppColors.primaryRed,
                backgroundColor: Colors.grey.shade100,
                side: BorderSide.none,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      tempSelectedCategories.add(category);
                    } else {
                      tempSelectedCategories.remove(category);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(homeScreenViewModelProvider.notifier).search(selectedCategories: tempSelectedCategories);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
