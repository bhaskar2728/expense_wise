import 'package:expense_wise/core/app_colors.dart';
import 'package:expense_wise/core/helper/category_helper.dart';
import 'package:expense_wise/data/model/expense_model.dart';
import 'package:expense_wise/presentation/view/screens/add_expense_screen.dart';
import 'package:expense_wise/presentation/viewmodel/home_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ExpenseTileWidget extends ConsumerWidget {
  final ExpenseModel expense;

  const ExpenseTileWidget({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) => AddOrUpdateExpenseScreen(expense: expense),
            ),
          )
          .then((value) {
            ref.read(homeScreenViewModelProvider.notifier).fetchAllExpenses();
          }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  DateFormat('MMM').format(expense.dateTime),
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 12,
                  ),
                ),
                Text(
                  DateFormat('dd').format(expense.dateTime),
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                CategoryHelper.getIcon(expense.category),
                color: CategoryHelper.getColor(expense.category),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Removed "You paid..." as it's redundant in a personal tracker
                ],
              ),
            ),
            // Modified to just show the amount, not "you lent/borrowed"
            Text(
              NumberFormat.currency(
                locale: 'en_IN',
                symbol: '₹',
              ).format(expense.amount),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
