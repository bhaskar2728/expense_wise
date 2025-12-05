import 'package:dart_either/dart_either.dart';
import 'package:expense_wise/data/enums/expense_category_enum.dart';
import 'package:expense_wise/data/model/expense_model.dart';
import 'package:expense_wise/data/model/failure_model.dart';
import 'package:expense_wise/data/service/expense_data_local_service_impl.dart';
import 'package:expense_wise/domain/repository/expense_data_repository.dart';
import 'package:expense_wise/domain/service/expense_data_local_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseDataRepositoryImpl extends ExpenseDataRepository {
  final ExpenseDataLocalService expenseDataLocalService;

  ExpenseDataRepositoryImpl({required this.expenseDataLocalService});

  @override
  Future<Either<Failure,ExpenseModel>> addExpense({
    required String title,
    required num amount,
    required ExpenseCategory category,
    required DateTime dateTime,
  }) async {
    final expense = ExpenseModel(
      title: title,
      amount: amount,
      category: category,
      dateTime: dateTime,
    );
    final response = await expenseDataLocalService.addExpense(
      expenseData: expense.toJson(),
    );
    if (response.success) {
      final id = response.data!['id'];
      expense.updateId(id: id);
      return Right(expense);
    } else {
      return Left(Failure(errorMsg: response.errorMsg!));
    }
  }

  @override
  Future<Either<Failure,bool>> deleteExpense({required int id}) async {
    final response = await expenseDataLocalService.deleteExpense(id: id);
    if (response.success) {
      return Right(true);
    } else {
      return Left(Failure(errorMsg: response.errorMsg!));
    }
  }

  @override
  Future<Either<Failure,List<ExpenseModel>>> getAllExpenses() async {
    final response = await expenseDataLocalService.getAllExpenses();
    if (response.success) {
      final listOfData = response.data as List<Map<String, dynamic>>;
      final listOfExpenses = listOfData
          .map((e) => ExpenseModel.fromJson(e))
          .toList();
      return Right(listOfExpenses);
    } else {
      return Left(Failure(errorMsg: response.errorMsg!));
    }
  }

  @override
  Future<Either<Failure,ExpenseModel>> updateExpense({
    required int id,
    required String title,
    required num amount,
    required ExpenseCategory category,
    required DateTime dateTime,
  }) async {
    final updatedExpense = ExpenseModel(
      id: id,
      title: title,
      amount: amount,
      category: category,
      dateTime: dateTime,
    );
    final response = await expenseDataLocalService.updateExpense(
      updatedExpenseData: updatedExpense.toJson(),
      id: id,
    );
    if (response.success) {
      return Right(updatedExpense);
    } else {
      return Left(Failure(errorMsg: response.errorMsg!));
    }
  }
}

final expenseDataRepositoryProvider = Provider<ExpenseDataRepository>(
  (ref) => ExpenseDataRepositoryImpl(
    expenseDataLocalService: ref.read(expenseDataLocalServiceImplProvider),
  ),);


