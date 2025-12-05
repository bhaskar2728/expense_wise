import 'package:expense_wise/core/app_colors.dart';
import 'package:expense_wise/core/helper/category_helper.dart';
import 'package:expense_wise/data/enums/expense_category_enum.dart';
import 'package:expense_wise/data/model/expense_model.dart';
import 'package:expense_wise/presentation/view/widgets/add_expense/bottom_options_widget.dart';
import 'package:expense_wise/presentation/view/widgets/add_expense/input_field.dart';
import 'package:expense_wise/presentation/viewmodel/add_expense_view_model.dart';
import 'package:expense_wise/presentation/viewmodel/home_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddOrUpdateExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseModel? expense;

  const AddOrUpdateExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddOrUpdateExpenseScreen> createState() =>
      _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddOrUpdateExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime selectedDateTime = DateTime.now();
  ExpenseCategory selectedCategory = ExpenseCategory.other;

  @override
  void initState() {
    if (widget.expense != null) {
      selectedDateTime = widget.expense!.dateTime;
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      selectedCategory = widget.expense!.category;
    }
    _titleController.addListener(
      () => ref
          .read(addExpenseViewModelProvider.notifier)
          .predictCategoryBasedOnText(_titleController.text.toLowerCase()),
    );
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      ref
          .read(addExpenseViewModelProvider.notifier)
          .updateCategory(selectedCategory);
      ref
          .read(addExpenseViewModelProvider.notifier)
          .updateDate(selectedDateTime);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(addExpenseViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.expense == null ? 'Add an expense' : 'Update expense',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: onSave,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.teal,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Removed "With you and..." row
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InputField(
                      controller: _titleController,
                      icon: CategoryHelper.getIcon(
                        ref.watch(addExpenseViewModelProvider).expenseCategory,
                      ),
                      color: CategoryHelper.getColor(
                        ref.watch(addExpenseViewModelProvider).expenseCategory,
                      ),
                      hintText: 'Enter a description',
                      isAmount: false,
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      controller: _amountController,
                      icon: Icons.currency_rupee,
                      hintText: '0.00',
                      isAmount: true,
                    ),
                    // Removed "Paid by you and split equally" row
                  ],
                ),
              ),
            ),
          ),
          BottomOptionsWidget(expense: widget.expense),
        ],
      ),
    );
  }

  void onSave() {
    final viewModel = ref.read(addExpenseViewModelProvider.notifier);
    if (!_formKey.currentState!.validate()) return;

    widget.expense == null
        ? viewModel.addExpense(
            title: _titleController.text,
            amount: double.parse(_amountController.text),
          )
        : viewModel.updateExpense(
            id: widget.expense!.id!,
            title: _titleController.text,
            amount: double.parse(_amountController.text),
          );
  }
}
