import 'package:dart_either/dart_either.dart';
import 'package:expense_wise/core/service/navigation_service.dart';
import 'package:expense_wise/data/enums/expense_category_enum.dart';
import 'package:expense_wise/data/model/expense_model.dart';
import 'package:expense_wise/data/model/failure_model.dart';
import 'package:expense_wise/data/repository/expense_data_repository_impl.dart';
import 'package:expense_wise/data/service/ui_helper_service_impl.dart';
import 'package:expense_wise/domain/repository/expense_data_repository.dart';
import 'package:expense_wise/domain/service/ui_helper_service.dart';
import 'package:expense_wise/presentation/viewmodel/home_screen_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockExpenseDataRepository extends Mock implements ExpenseDataRepository {}

class MockUIHelperService extends Mock implements UIHelperService {}

class MockNavigationService extends Mock implements NavigationService {}

void main() {
  late MockExpenseDataRepository mockRepository;
  late MockUIHelperService mockUIHelperService;
  late ProviderContainer container;

  // Test data factory
  final tExpenseModel1 = ExpenseModel(
    id: 1,
    title: 'Grocery Shopping',
    amount: 150.50,
    category: ExpenseCategory.food,
    dateTime: DateTime.now(),
  );

  final tExpenseModel2 = ExpenseModel(
    id: 2,
    title: 'Uber Ride',
    amount: 25.00,
    category: ExpenseCategory.transport,
    dateTime: DateTime.now().subtract(const Duration(days: 1)),
  );

  final tExpenseList = [tExpenseModel1, tExpenseModel2];

  setUp(() {
    mockRepository = MockExpenseDataRepository();
    mockUIHelperService = MockUIHelperService();

    // Create a ProviderContainer and override the dependencies
    container = ProviderContainer(
      overrides: [
        expenseDataRepositoryProvider.overrideWithValue(mockRepository),
        // Override the homeScreenViewModelProvider directly
        homeScreenViewModelProvider.overrideWith((ref) {
          return HomeScreenViewModel(
            expenseDataRepository: mockRepository,
            uiHelperService: mockUIHelperService,
          );
        }),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('HomeScreenViewModel - Initialization', () {
    test(
      'Given ViewModel is created, '
      'When initialized, '
      'Then state should start with isLoading: true',
      () {
        // Arrange
        when(() => mockRepository.getAllExpenses())
            .thenAnswer((_) async => Right(tExpenseList));

        // Act
        final viewModel = container.read(homeScreenViewModelProvider.notifier);
        final initialState = container.read(homeScreenViewModelProvider);

        // Assert - Check initial state before async completion
        expect(initialState.isLoading, true);
        expect(initialState.allExpenses, isEmpty);
        expect(initialState.totalSpent, 0);
      },
    );

    test(
      'Given repository returns success, '
      'When ViewModel initializes and fetches expenses, '
      'Then state should contain expense list and isLoading: false',
      () async {
        // Arrange
        when(() => mockRepository.getAllExpenses())
            .thenAnswer((_) async => Right(tExpenseList));

        // Act
        final viewModel = container.read(homeScreenViewModelProvider.notifier);

        // Wait for async initialization to complete
        await Future.delayed(const Duration(milliseconds: 100));

        final state = container.read(homeScreenViewModelProvider);

        // Assert
        expect(state.isLoading, false);
        expect(state.allExpenses, tExpenseList);
        expect(state.allExpenses.length, 2);
        expect(state.groupedExpenses, isNotEmpty);
        verify(() => mockRepository.getAllExpenses()).called(1);
      },
    );

    test(
      'Given repository returns success with current month expenses, '
      'When ViewModel initializes, '
      'Then totalSpent should be calculated correctly for current month',
      () async {
        // Arrange
        final now = DateTime.now();
        final currentMonthExpenses = [
          ExpenseModel(
            id: 1,
            title: 'Expense 1',
            amount: 100,
            category: ExpenseCategory.food,
            dateTime: DateTime(now.year, now.month, 5),
          ),
          ExpenseModel(
            id: 2,
            title: 'Expense 2',
            amount: 50,
            category: ExpenseCategory.transport,
            dateTime: DateTime(now.year, now.month, 10),
          ),
          ExpenseModel(
            id: 3,
            title: 'Expense 3 - Last Month',
            amount: 200,
            category: ExpenseCategory.shopping,
            dateTime: DateTime(now.year, now.month - 1, 15),
          ),
        ];

        when(() => mockRepository.getAllExpenses())
            .thenAnswer((_) async => Right(currentMonthExpenses));

        // Act
        final viewModel = container.read(homeScreenViewModelProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));

        final state = container.read(homeScreenViewModelProvider);

        // Assert - totalSpent should only include current month expenses (100 + 50)
        expect(state.totalSpent, 150);
        expect(state.isLoading, false);
        expect(state.allExpenses.length, 3);
        verify(() => mockRepository.getAllExpenses()).called(1);
      },
    );

    test(
      'Given repository returns failure, '
      'When ViewModel initializes, '
      'Then state should have empty list, isLoading: false, and show error',
      () async {
        // Arrange
        final tFailure = Failure(errorMsg: 'Database connection failed');
        when(() => mockRepository.getAllExpenses())
            .thenAnswer((_) async => Left(tFailure));

        // Act
        final viewModel = container.read(homeScreenViewModelProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));

        final state = container.read(homeScreenViewModelProvider);

        // Assert
        expect(state.isLoading, false);
        expect(state.allExpenses, isEmpty);
        expect(state.groupedExpenses, isEmpty);
        verify(() => mockRepository.getAllExpenses()).called(1);
        verify(() => mockUIHelperService.showSnackBar(
              msg: tFailure.errorMsg,
            )).called(1);
      },
    );
  });

  group('HomeScreenViewModel - fetchAllExpenses', () {
    test(
      'Given repository returns Right with expense list, '
      'When fetchAllExpenses is called, '
      'Then state should be updated with expenses and isLoading: false',
      () async {
        // Arrange
        when(() => mockRepository.getAllExpenses())
            .thenAnswer((_) async => Right(tExpenseList));

        // Act
        final viewModel = container.read(homeScreenViewModelProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));

        // Call fetchAllExpenses explicitly
        viewModel.fetchAllExpenses();
        await Future.delayed(const Duration(milliseconds: 100));

        final state = container.read(homeScreenViewModelProvider);

        // Assert
        expect(state.isLoading, false);
        expect(state.allExpenses, isNotEmpty);
        expect(state.allExpenses.length, tExpenseList.length);
        expect(state.allExpenses.first.id, tExpenseModel1.id);
        expect(state.allExpenses.first.title, tExpenseModel1.title);
        // Called twice: once on init, once explicitly
        verify(() => mockRepository.getAllExpenses()).called(2);
      },
    );

    test(
      'Given repository returns Left with Failure, '
      'When fetchAllExpenses is called, '
      'Then state should have empty list and error should be shown',
      () async {
        // Arrange
        final tErrorMessage = 'Network error occurred';
        final tFailure = Failure(errorMsg: tErrorMessage);
        when(() => mockRepository.getAllExpenses())
            .thenAnswer((_) async => Left(tFailure));

        // Act
        final viewModel = container.read(homeScreenViewModelProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));

        final state = container.read(homeScreenViewModelProvider);

        // Assert
        expect(state.isLoading, false);
        expect(state.allExpenses, isEmpty);
        expect(state.groupedExpenses, isEmpty);
        verify(() => mockRepository.getAllExpenses()).called(1);
        verify(() => mockUIHelperService.showSnackBar(msg: tErrorMessage))
            .called(1);
      },
    );

    test(
      'Given successful fetch, '
      'When expenses are grouped, '
      'Then groupedExpenses map should be organized by month-year',
      () async {
        // Arrange
        final expensesAcrossMonths = [
          ExpenseModel(
            id: 1,
            title: 'December Expense',
            amount: 100,
            category: ExpenseCategory.food,
            dateTime: DateTime(2024, 12, 5),
          ),
          ExpenseModel(
            id: 2,
            title: 'November Expense',
            amount: 50,
            category: ExpenseCategory.transport,
            dateTime: DateTime(2024, 11, 20),
          ),
          ExpenseModel(
            id: 3,
            title: 'Another December Expense',
            amount: 75,
            category: ExpenseCategory.shopping,
            dateTime: DateTime(2024, 12, 15),
          ),
        ];

        when(() => mockRepository.getAllExpenses())
            .thenAnswer((_) async => Right(expensesAcrossMonths));

        // Act
        final viewModel = container.read(homeScreenViewModelProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));

        final state = container.read(homeScreenViewModelProvider);

        // Assert
        expect(state.groupedExpenses.length, 2); // December and November
        expect(state.groupedExpenses.containsKey('December 2024'), true);
        expect(state.groupedExpenses.containsKey('November 2024'), true);
        expect(state.groupedExpenses['December 2024']?.length, 2);
        expect(state.groupedExpenses['November 2024']?.length, 1);
        verify(() => mockRepository.getAllExpenses()).called(1);
      },
    );
  });

  group('HomeScreenViewModel - search', () {
    test(
      'Given expenses are loaded, '
      'When search is called with searchQuery, '
      'Then groupedExpenses should filter by search query',
      () async {
        // Arrange
        final expenses = [
          ExpenseModel(
            id: 1,
            title: 'Grocery Shopping',
            amount: 100,
            category: ExpenseCategory.food,
            dateTime: DateTime.now(),
          ),
          ExpenseModel(
            id: 2,
            title: 'Uber Ride',
            amount: 50,
            category: ExpenseCategory.transport,
            dateTime: DateTime.now(),
          ),
        ];

        when(() => mockRepository.getAllExpenses())
            .thenAnswer((_) async => Right(expenses));

        final viewModel = container.read(homeScreenViewModelProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        viewModel.search(searchQuery: 'grocery');
        final state = container.read(homeScreenViewModelProvider);

        // Assert
        expect(state.searchQuery, 'grocery');
        // The grouped expenses should only contain items matching "grocery"
        final allFilteredExpenses = state.groupedExpenses.values
            .expand((list) => list)
            .toList();
        expect(allFilteredExpenses.length, 1);
        expect(allFilteredExpenses.first.title.toLowerCase(),
            contains('grocery'));
      },
    );

    test(
      'Given expenses are loaded, '
      'When search is called with selectedCategories, '
      'Then groupedExpenses should filter by category',
      () async {
        // Arrange
        final expenses = [
          ExpenseModel(
            id: 1,
            title: 'Grocery',
            amount: 100,
            category: ExpenseCategory.food,
            dateTime: DateTime.now(),
          ),
          ExpenseModel(
            id: 2,
            title: 'Uber',
            amount: 50,
            category: ExpenseCategory.transport,
            dateTime: DateTime.now(),
          ),
          ExpenseModel(
            id: 3,
            title: 'Shopping',
            amount: 75,
            category: ExpenseCategory.shopping,
            dateTime: DateTime.now(),
          ),
        ];

        when(() => mockRepository.getAllExpenses())
            .thenAnswer((_) async => Right(expenses));

        final viewModel = container.read(homeScreenViewModelProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        viewModel.search(
          searchQuery: '',
          selectedCategories: {ExpenseCategory.food},
        );
        final state = container.read(homeScreenViewModelProvider);

        // Assert
        expect(state.selectedCategories, {ExpenseCategory.food});
        final allFilteredExpenses = state.groupedExpenses.values
            .expand((list) => list)
            .toList();
        expect(allFilteredExpenses.length, 1);
        expect(allFilteredExpenses.first.category, ExpenseCategory.food);
      },
    );

    test(
      'Given expenses are loaded, '
      'When search is called with both query and categories, '
      'Then groupedExpenses should filter by both criteria',
      () async {
        // Arrange
        final expenses = [
          ExpenseModel(
            id: 1,
            title: 'Grocery Shopping',
            amount: 100,
            category: ExpenseCategory.food,
            dateTime: DateTime.now(),
          ),
          ExpenseModel(
            id: 2,
            title: 'Food Delivery',
            amount: 30,
            category: ExpenseCategory.food,
            dateTime: DateTime.now(),
          ),
          ExpenseModel(
            id: 3,
            title: 'Uber',
            amount: 50,
            category: ExpenseCategory.transport,
            dateTime: DateTime.now(),
          ),
        ];

        when(() => mockRepository.getAllExpenses())
            .thenAnswer((_) async => Right(expenses));

        final viewModel = container.read(homeScreenViewModelProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        viewModel.search(
          searchQuery: 'grocery',
          selectedCategories: {ExpenseCategory.food},
        );
        final state = container.read(homeScreenViewModelProvider);

        // Assert
        expect(state.searchQuery, 'grocery');
        expect(state.selectedCategories, {ExpenseCategory.food});
        final allFilteredExpenses = state.groupedExpenses.values
            .expand((list) => list)
            .toList();
        expect(allFilteredExpenses.length, 1);
        expect(allFilteredExpenses.first.title, 'Grocery Shopping');
        expect(allFilteredExpenses.first.category, ExpenseCategory.food);
      },
    );
  });
}

