import 'package:expense_wise/data/enums/expense_category_enum.dart';
import 'package:flutter/material.dart';

class CategoryHelper {
  static IconData getIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food: return Icons.restaurant;
      case ExpenseCategory.transport: return Icons.directions_car;
      case ExpenseCategory.shopping: return Icons.shopping_bag;
      case ExpenseCategory.entertainment: return Icons.movie;
      case ExpenseCategory.health: return Icons.favorite;
      case ExpenseCategory.other: return Icons.receipt;
    }
  }

  static Color getColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food: return Colors.orange;
      case ExpenseCategory.transport: return Colors.blue;
      case ExpenseCategory.shopping: return Colors.purple;
      case ExpenseCategory.entertainment: return Colors.red;
      case ExpenseCategory.health: return Colors.green;
      case ExpenseCategory.other: return Colors.black;
    }
  }
}