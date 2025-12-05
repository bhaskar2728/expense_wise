import 'package:expense_wise/data/model/expense_model.dart';

class ExpenseRepoResponse {
  final bool success;
  final String? errorMsg;
  final List<ExpenseModel>? expenseList;
  final ExpenseModel? expense;
  final String? id;

  ExpenseRepoResponse({
    required this.success,
    this.errorMsg,
    this.expenseList,
    this.id,
    this.expense,
  });
}
