import 'package:dart_either/dart_either.dart';
import 'package:expense_wise/data/enums/expense_category_enum.dart';
import 'package:expense_wise/data/model/expense_model.dart';
import 'package:expense_wise/data/model/failure_model.dart';

abstract class ExpenseDataRepository{

  Future<Either<Failure,List<ExpenseModel>>> getAllExpenses();
  Future<Either<Failure,ExpenseModel>> addExpense({required String title,required num amount,required ExpenseCategory category, required DateTime dateTime,});
  Future<Either<Failure,ExpenseModel>> updateExpense({required int id,required String title,required num amount,required ExpenseCategory category, required DateTime dateTime,});
  Future<Either<Failure,bool>> deleteExpense({required int id});

}