import 'package:expense_wise/core/constants.dart';
import 'package:expense_wise/data/enums/expense_category_enum.dart';

class ExpenseModel {
  int? id;
  final String title;
  final ExpenseCategory category;
  final num amount;
  final DateTime dateTime;

  ExpenseModel({
    required this.title,
    required this.category,
    required this.amount,
    required this.dateTime,
    this.id,
  });

  void updateId({required int id}){
    this.id = id;
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json[Constants.id],
      title: json[Constants.title],
      category: json[Constants.category].toString().toExpenseCategory(),
      amount: json[Constants.amount],
      dateTime: DateTime.parse(json[Constants.dateTime]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      Constants.title: title,
      Constants.category: category.name,
      Constants.amount: amount,
      Constants.dateTime: dateTime.toIso8601String(),
    };
  }
}
