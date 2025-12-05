import 'package:dart_either/dart_either.dart';
import 'package:expense_wise/data/enums/expense_category_enum.dart';
import 'package:expense_wise/data/model/expense_local_service_response.dart';
import 'package:expense_wise/data/model/expense_model.dart';
import 'package:expense_wise/data/model/failure_model.dart';
import 'package:expense_wise/data/repository/expense_data_repository_impl.dart';
import 'package:expense_wise/domain/service/expense_data_local_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock class for ExpenseDataLocalService
class MockExpenseDataLocalService extends Mock
    implements ExpenseDataLocalService {}

void main() {
  late ExpenseDataRepositoryImpl repository;
  late MockExpenseDataLocalService mockLocalService;

  // Test data factory
  final tExpenseModel = ExpenseModel(
    id: 1,
    title: 'Grocery Shopping',
    amount: 150.50,
    category: ExpenseCategory.food,
    dateTime: DateTime(2024, 12, 5),
  );

  final tExpenseModelWithoutId = ExpenseModel(
    title: 'Grocery Shopping',
    amount: 150.50,
    category: ExpenseCategory.food,
    dateTime: DateTime(2024, 12, 5),
  );

  final tExpenseList = [
    tExpenseModel,
    ExpenseModel(
      id: 2,
      title: 'Uber Ride',
      amount: 25.00,
      category: ExpenseCategory.transport,
      dateTime: DateTime(2024, 12, 4),
    ),
  ];

  setUp(() {
    mockLocalService = MockExpenseDataLocalService();
    repository = ExpenseDataRepositoryImpl(
      expenseDataLocalService: mockLocalService,
    );
  });

  tearDown(() {
    reset(mockLocalService);
  });

  group('ExpenseDataRepositoryImpl - getAllExpenses', () {
    test(
      'Given local service returns success response, '
      'When getAllExpenses is called, '
      'Then should return Right with List<ExpenseModel>',
      () async {
        // Arrange
        // Create JSON with id field manually since toJson() doesn't include it
        final tExpenseListJson = [
          {
            'id': tExpenseModel.id,
            'title': tExpenseModel.title,
            'amount': tExpenseModel.amount,
            'category': tExpenseModel.category.name,
            'dateTime': tExpenseModel.dateTime.toIso8601String(),
          },
          {
            'id': tExpenseList[1].id,
            'title': tExpenseList[1].title,
            'amount': tExpenseList[1].amount,
            'category': tExpenseList[1].category.name,
            'dateTime': tExpenseList[1].dateTime.toIso8601String(),
          },
        ];
        final tSuccessResponse = ExpenseLocalServiceResponse(
          success: true,
          data: tExpenseListJson,
        );

        when(() => mockLocalService.getAllExpenses())
            .thenAnswer((_) async => tSuccessResponse);

        // Act
        final result = await repository.getAllExpenses();

        // Assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (_) => fail('Should not return Left'),
          ifRight: (expenses) {
            expect(expenses, isA<List<ExpenseModel>>());
            expect(expenses.length, tExpenseList.length);
            expect(expenses.first.id, tExpenseList.first.id);
            expect(expenses.first.title, tExpenseList.first.title);
            expect(expenses.first.amount, tExpenseList.first.amount);
            expect(expenses.first.category, tExpenseList.first.category);
          },
        );
        verify(() => mockLocalService.getAllExpenses()).called(1);
      },
    );

    test(
      'Given local service returns failure response, '
      'When getAllExpenses is called, '
      'Then should return Left with Failure',
      () async {
        // Arrange
        final tErrorMessage = 'Database connection failed';
        final tFailureResponse = ExpenseLocalServiceResponse(
          success: false,
          errorMsg: tErrorMessage,
        );

        when(() => mockLocalService.getAllExpenses())
            .thenAnswer((_) async => tFailureResponse);

        // Act
        final result = await repository.getAllExpenses();

        // Assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (failure) {
            expect(failure, isA<Failure>());
            expect(failure.errorMsg, tErrorMessage);
          },
          ifRight: (_) => fail('Should not return Right'),
        );
        verify(() => mockLocalService.getAllExpenses()).called(1);
      },
    );

    test(
      'Given local service throws an exception, '
      'When getAllExpenses is called, '
      'Then should propagate the exception',
      () async {
        // Arrange
        when(() => mockLocalService.getAllExpenses())
            .thenThrow(Exception('Unexpected error'));

        // Act & Assert
        expect(
          () => repository.getAllExpenses(),
          throwsA(isA<Exception>()),
        );
        verify(() => mockLocalService.getAllExpenses()).called(1);
      },
    );
  });

  group('ExpenseDataRepositoryImpl - addExpense', () {
    test(
      'Given local service returns success with valid ID, '
      'When addExpense is called, '
      'Then should return Right with ExpenseModel containing the ID',
      () async {
        // Arrange
        final tExpenseId = 42;
        final tSuccessResponse = ExpenseLocalServiceResponse(
          success: true,
          data: {'id': tExpenseId},
        );

        when(() => mockLocalService.addExpense(
              expenseData: any(named: 'expenseData'),
            )).thenAnswer((_) async => tSuccessResponse);

        // Act
        final result = await repository.addExpense(
          title: tExpenseModelWithoutId.title,
          amount: tExpenseModelWithoutId.amount,
          category: tExpenseModelWithoutId.category,
          dateTime: tExpenseModelWithoutId.dateTime,
        );

        // Assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (_) => fail('Should not return Left'),
          ifRight: (expense) {
            expect(expense, isA<ExpenseModel>());
            expect(expense.id, tExpenseId);
            expect(expense.title, tExpenseModelWithoutId.title);
            expect(expense.amount, tExpenseModelWithoutId.amount);
            expect(expense.category, tExpenseModelWithoutId.category);
            expect(expense.dateTime, tExpenseModelWithoutId.dateTime);
          },
        );
        verify(() => mockLocalService.addExpense(
              expenseData: any(named: 'expenseData'),
            )).called(1);
      },
    );

    test(
      'Given local service returns failure response, '
      'When addExpense is called, '
      'Then should return Left with Failure',
      () async {
        // Arrange
        final tErrorMessage = 'Unable to add expense';
        final tFailureResponse = ExpenseLocalServiceResponse(
          success: false,
          errorMsg: tErrorMessage,
        );

        when(() => mockLocalService.addExpense(
              expenseData: any(named: 'expenseData'),
            )).thenAnswer((_) async => tFailureResponse);

        // Act
        final result = await repository.addExpense(
          title: tExpenseModelWithoutId.title,
          amount: tExpenseModelWithoutId.amount,
          category: tExpenseModelWithoutId.category,
          dateTime: tExpenseModelWithoutId.dateTime,
        );

        // Assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (failure) {
            expect(failure, isA<Failure>());
            expect(failure.errorMsg, tErrorMessage);
          },
          ifRight: (_) => fail('Should not return Right'),
        );
        verify(() => mockLocalService.addExpense(
              expenseData: any(named: 'expenseData'),
            )).called(1);
      },
    );

    test(
      'Given local service throws an exception, '
      'When addExpense is called, '
      'Then should propagate the exception',
      () async {
        // Arrange
        when(() => mockLocalService.addExpense(
              expenseData: any(named: 'expenseData'),
            )).thenThrow(Exception('Database write failed'));

        // Act & Assert
        expect(
          () => repository.addExpense(
            title: tExpenseModelWithoutId.title,
            amount: tExpenseModelWithoutId.amount,
            category: tExpenseModelWithoutId.category,
            dateTime: tExpenseModelWithoutId.dateTime,
          ),
          throwsA(isA<Exception>()),
        );
        verify(() => mockLocalService.addExpense(
              expenseData: any(named: 'expenseData'),
            )).called(1);
      },
    );
  });

  group('ExpenseDataRepositoryImpl - updateExpense', () {
    test(
      'Given local service returns success response, '
      'When updateExpense is called, '
      'Then should return Right with updated ExpenseModel',
      () async {
        // Arrange
        final tSuccessResponse = ExpenseLocalServiceResponse(
          success: true,
        );

        when(() => mockLocalService.updateExpense(
              updatedExpenseData: any(named: 'updatedExpenseData'),
              id: any(named: 'id'),
            )).thenAnswer((_) async => tSuccessResponse);

        // Act
        final result = await repository.updateExpense(
          id: tExpenseModel.id!,
          title: 'Updated Title',
          amount: 200.00,
          category: ExpenseCategory.shopping,
          dateTime: tExpenseModel.dateTime,
        );

        // Assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (_) => fail('Should not return Left'),
          ifRight: (expense) {
            expect(expense, isA<ExpenseModel>());
            expect(expense.id, tExpenseModel.id);
            expect(expense.title, 'Updated Title');
            expect(expense.amount, 200.00);
            expect(expense.category, ExpenseCategory.shopping);
          },
        );
        verify(() => mockLocalService.updateExpense(
              updatedExpenseData: any(named: 'updatedExpenseData'),
              id: tExpenseModel.id!,
            )).called(1);
      },
    );

    test(
      'Given local service returns failure response, '
      'When updateExpense is called, '
      'Then should return Left with Failure',
      () async {
        // Arrange
        final tErrorMessage = 'Unable to update expense';
        final tFailureResponse = ExpenseLocalServiceResponse(
          success: false,
          errorMsg: tErrorMessage,
        );

        when(() => mockLocalService.updateExpense(
              updatedExpenseData: any(named: 'updatedExpenseData'),
              id: any(named: 'id'),
            )).thenAnswer((_) async => tFailureResponse);

        // Act
        final result = await repository.updateExpense(
          id: tExpenseModel.id!,
          title: 'Updated Title',
          amount: 200.00,
          category: ExpenseCategory.shopping,
          dateTime: tExpenseModel.dateTime,
        );

        // Assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (failure) {
            expect(failure, isA<Failure>());
            expect(failure.errorMsg, tErrorMessage);
          },
          ifRight: (_) => fail('Should not return Right'),
        );
        verify(() => mockLocalService.updateExpense(
              updatedExpenseData: any(named: 'updatedExpenseData'),
              id: tExpenseModel.id!,
            )).called(1);
      },
    );
  });

  group('ExpenseDataRepositoryImpl - deleteExpense', () {
    test(
      'Given local service returns success response, '
      'When deleteExpense is called, '
      'Then should return Right with true',
      () async {
        // Arrange
        final tSuccessResponse = ExpenseLocalServiceResponse(
          success: true,
        );

        when(() => mockLocalService.deleteExpense(id: any(named: 'id')))
            .thenAnswer((_) async => tSuccessResponse);

        // Act
        final result = await repository.deleteExpense(id: tExpenseModel.id!);

        // Assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (_) => fail('Should not return Left'),
          ifRight: (success) {
            expect(success, true);
          },
        );
        verify(() => mockLocalService.deleteExpense(id: tExpenseModel.id!))
            .called(1);
      },
    );

    test(
      'Given local service returns failure response, '
      'When deleteExpense is called, '
      'Then should return Left with Failure',
      () async {
        // Arrange
        final tErrorMessage = 'Unable to delete expense';
        final tFailureResponse = ExpenseLocalServiceResponse(
          success: false,
          errorMsg: tErrorMessage,
        );

        when(() => mockLocalService.deleteExpense(id: any(named: 'id')))
            .thenAnswer((_) async => tFailureResponse);

        // Act
        final result = await repository.deleteExpense(id: tExpenseModel.id!);

        // Assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (failure) {
            expect(failure, isA<Failure>());
            expect(failure.errorMsg, tErrorMessage);
          },
          ifRight: (_) => fail('Should not return Right'),
        );
        verify(() => mockLocalService.deleteExpense(id: tExpenseModel.id!))
            .called(1);
      },
    );
  });
}

