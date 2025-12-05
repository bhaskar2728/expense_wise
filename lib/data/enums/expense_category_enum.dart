enum ExpenseCategory { food, transport, shopping, entertainment, health, other, }

extension CategoryParsing on String {
  ExpenseCategory toExpenseCategory() {
    return ExpenseCategory.values.firstWhere(
          (e) => e.name == this,
      orElse: () => ExpenseCategory.other, // Default fallback
    );
  }
}

extension ExpenseCategoryParsing on ExpenseCategory {
  String toCategoryProper() {
    switch(this){
      case ExpenseCategory.food:
        return "Food";
      case ExpenseCategory.transport:
        return "Transport";
      case ExpenseCategory.shopping:
        return "Shopping";
      case ExpenseCategory.entertainment:
        return "Entertainment";
      case ExpenseCategory.health:
        return "Health";
      default:
        return "Other";

    }
  }
}