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
  ConsumerState<AddOrUpdateExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddOrUpdateExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DateTime selectedDateTime = DateTime.now();
  ExpenseCategory selectedCategory = ExpenseCategory.other;
  @override
  void initState() {
    if(widget.expense != null){
      selectedDateTime = widget.expense!.dateTime;
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      selectedCategory = widget.expense!.category;
    }
    _titleController.addListener(_updateCategoryIcon);
    WidgetsBinding.instance.addPostFrameCallback(
        (timestamp){
          ref.read(addExpenseViewModelProvider.notifier).updateCategory(selectedCategory);
          ref.read(addExpenseViewModelProvider.notifier).updateDate(selectedDateTime);
        }
    );
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
            onPressed: () => widget.expense == null ? viewModel.addExpense(
              title: _titleController.text,
              amount: double.parse(_amountController.text),
            ) : viewModel.updateExpense(
              id: widget.expense!.id!,
              title: _titleController.text,
              amount: double.parse(_amountController.text),
            ),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InputField(
                    controller: _titleController,
                    icon: CategoryHelper.getIcon(ref.watch(addExpenseViewModelProvider).expenseCategory),
                    color: CategoryHelper.getColor(ref.watch(addExpenseViewModelProvider).expenseCategory),
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
          BottomOptionsWidget(expense: widget.expense,),
        ],
      ),
    );
  }

  void _updateCategoryIcon() {
    final text = _titleController.text.toLowerCase();
    ExpenseCategory newCategory = ExpenseCategory.other; // Default 'Other'

    // Logic to detect category from text
    if (_containsAny(text, ['food', 'lunch', 'dinner', 'breakfast', 'meal', 'restaurant', 'cafe', 'coffee', 'burger', 'pizza', 'groceries', 'snack'])) {
      newCategory = ExpenseCategory.food; // Food
    } else if (_containsAny(text, ['transport', 'uber', 'cab', 'taxi', 'bus', 'train', 'flight', 'fuel', 'petrol', 'gas', 'parking', 'travel'])) {
      newCategory = ExpenseCategory.transport;// Transport
    } else if (_containsAny(text, ['shopping', 'clothes', 'shoes', 'amazon', 'flipkart', 'market', 'mall', 'buy'])) {
      newCategory = ExpenseCategory.shopping;// Shopping
    } else if (_containsAny(text, ['entertainment', 'movie', 'cinema', 'film', 'netflix', 'game', 'party', 'concert', 'fun'])) {
      newCategory = ExpenseCategory.entertainment; // Entertainment (Using Movie icon as proxy)
    } else if (_containsAny(text, ['health', 'doctor', 'medicine', 'pharmacy', 'hospital', 'gym', 'workout', 'meds'])) {
      newCategory = ExpenseCategory.health;// Health
    }

    if (newCategory != selectedCategory) {
      selectedCategory = newCategory;
      ref.read(addExpenseViewModelProvider.notifier).updateCategory(newCategory);
    }
  }

  bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) return true;
    }
    return false;
  }
}
