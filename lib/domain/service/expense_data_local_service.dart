import 'package:expense_wise/data/model/expense_local_service_response.dart';

abstract class ExpenseDataLocalService{

  Future<ExpenseLocalServiceResponse> getAllExpenses();
  Future<ExpenseLocalServiceResponse> addExpense({required Map<String,dynamic> expenseData});
  Future<ExpenseLocalServiceResponse> updateExpense({required Map<String,dynamic> updatedExpenseData,required int id});
  Future<ExpenseLocalServiceResponse> deleteExpense({required int id});

}