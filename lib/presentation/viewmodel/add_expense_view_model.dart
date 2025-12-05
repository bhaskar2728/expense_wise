import 'package:expense_wise/core/service/navigation_service.dart';
import 'package:expense_wise/data/enums/expense_category_enum.dart';
import 'package:expense_wise/data/repository/expense_data_repository_impl.dart';
import 'package:expense_wise/data/service/ui_helper_service_impl.dart';
import 'package:expense_wise/domain/repository/expense_data_repository.dart';
import 'package:expense_wise/domain/service/ui_helper_service.dart';
import 'package:flutter_riverpod/legacy.dart';

class AddExpenseState {
  final DateTime selectedDateTime;
  final ExpenseCategory expenseCategory;

  AddExpenseState({
    required this.selectedDateTime,
    required this.expenseCategory,
  });

  AddExpenseState.initial()
    : this(
        selectedDateTime: DateTime.now(),
        expenseCategory: ExpenseCategory.other,
      );

  AddExpenseState copyWith({DateTime? date, ExpenseCategory? category}) {
    return AddExpenseState(
      selectedDateTime: date ?? selectedDateTime,
      expenseCategory: category ?? expenseCategory,
    );
  }
}

class AddExpenseViewModel extends StateNotifier<AddExpenseState> {
  final ExpenseDataRepository expenseDataRepository;
  final UIHelperService uiHelperService;

  AddExpenseViewModel({
    required this.expenseDataRepository,
    required this.uiHelperService,
  }) : super(AddExpenseState.initial());

  void addExpense({required String title, required double amount}) async {
    final response = await expenseDataRepository.addExpense(
      title: title,
      amount: amount,
      category: state.expenseCategory,
      dateTime: state.selectedDateTime,
    );
    response.fold(
      ifLeft: (failure) {
        uiHelperService.showSnackBar(msg: failure.errorMsg);
      },
      ifRight: (expense) {
        uiHelperService.showSnackBar(msg: "Expense added successfully");
        uiHelperService.goBackToPreviousScreen();
      },
    );
  }

  void updateExpense({
    required int id,
    required String title,
    required double amount,
  }) async {
    final response = await expenseDataRepository.updateExpense(
      id: id,
      title: title,
      amount: amount,
      category: state.expenseCategory,
      dateTime: DateTime.now(),
    );

    response.fold(
      ifLeft: (failure) {
        uiHelperService.showSnackBar(msg: failure.errorMsg);
      },
      ifRight: (expense) {
        uiHelperService.showSnackBar(msg: "Expense updated successfully");
        uiHelperService.goBackToPreviousScreen();
      },
    );
  }

  void deleteExpense({required int id}) async {
    final response = await expenseDataRepository.deleteExpense(id: id);

    response.fold(
      ifLeft: (failure) {
        uiHelperService.showSnackBar(msg: failure.errorMsg);
      },
      ifRight: (expense) {
        uiHelperService.showSnackBar(msg: "Expense deleted successfully");
        uiHelperService.goBackToPreviousScreen();
      },
    );
  }

  void updateDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void updateCategory(ExpenseCategory category) {
    state = state.copyWith(category: category);
  }
}

final addExpenseViewModelProvider = StateNotifierProvider(
  (ref) => AddExpenseViewModel(
    expenseDataRepository: ref.read(expenseDataRepositoryProvider),
    uiHelperService: ref.read(uiServiceHelperProvider),
  ),
);
