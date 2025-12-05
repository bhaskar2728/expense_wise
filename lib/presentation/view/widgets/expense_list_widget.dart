import 'package:expense_wise/core/app_colors.dart';
import 'package:expense_wise/presentation/view/widgets/expense_tile_widget.dart';
import 'package:expense_wise/presentation/viewmodel/home_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseListWidget extends ConsumerWidget {
  const ExpenseListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeScreenViewModelProvider);

    if (state.groupedExpenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 10),
              Text('No expenses found', style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: state.groupedExpenses.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                entry.key,
                style: const TextStyle(color: AppColors.greyText, fontWeight: FontWeight.bold),
              ),
            ),
            ...entry.value.map((expense) => ExpenseTileWidget(expense: expense)),
          ],
        );
      }).toList(),
    );
  }
}
