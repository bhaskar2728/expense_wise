import 'package:expense_wise/core/app_colors.dart';
import 'package:expense_wise/presentation/view/widgets/filter_bottom_sheet.dart';
import 'package:expense_wise/presentation/viewmodel/home_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchBarFilterIconWidget extends ConsumerWidget {
  const SearchBarFilterIconWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final state = ref.watch(homeScreenViewModelProvider);
    final viewModel = ref.read(homeScreenViewModelProvider.notifier);

    return Row(
      children: [
        // 1. Expanded Search Bar
        Expanded(
          child: TextField(
            onChanged: (value) => viewModel.search(searchQuery: value),
            decoration: InputDecoration(
              hintText: 'Search expenses...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 2. Filter Icon Button with Badge
        GestureDetector(
          onTap: ()=>_showFilterBottomSheet(context),
          child: Container(
            height: 48, // Match standard input height
            width: 48,
            decoration: BoxDecoration(
              color: state.selectedCategories.isNotEmpty
                  ? AppColors.primaryRed.withOpacity(0.1) // Light red bg if active
                  : Colors.grey.shade100, // Grey if inactive
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.filter_list,
                  color: state.selectedCategories.isNotEmpty
                      ? AppColors.primaryRed
                      : Colors.grey.shade700,
                ),
                // The Red Dot Indicator
                if (state.selectedCategories.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet()
    );
  }
}
