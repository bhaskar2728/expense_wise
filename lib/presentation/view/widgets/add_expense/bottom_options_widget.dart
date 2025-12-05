import 'package:expense_wise/core/app_colors.dart';
import 'package:expense_wise/data/model/expense_model.dart';
import 'package:expense_wise/presentation/viewmodel/add_expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
class BottomOptionsWidget extends ConsumerStatefulWidget {
  final ExpenseModel? expense;
  const BottomOptionsWidget({super.key, this.expense});

  @override
  ConsumerState<BottomOptionsWidget> createState() => _BottomOptionsWidgetState();
}

class _BottomOptionsWidgetState extends ConsumerState<BottomOptionsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: _presentDatePicker,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(formattedDate(ref.watch(addExpenseViewModelProvider).selectedDateTime)),
          ),
          const Spacer(),
          // Removed the group selector ("New Flat")
          widget.expense != null ? IconButton(
            onPressed: ()=>ref.read(addExpenseViewModelProvider.notifier).deleteExpense(id: widget.expense!.id!,),
            icon: const Icon(Icons.delete, color: AppColors.teal),
          ) : const SizedBox(),
        ],
      ),
    );
  }

  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: ref.watch(addExpenseViewModelProvider).selectedDateTime,
      firstDate: firstDate,
      lastDate: now,
      // Optional: Theme the picker to match your Red app color
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryRed, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      ref.read(addExpenseViewModelProvider.notifier).updateDate(pickedDate);
    }
  }

  String formattedDate(DateTime _selectedDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selected == today) {
      return 'Today';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return DateFormat('dd MMM, yyyy').format(_selectedDate);
  }
}
