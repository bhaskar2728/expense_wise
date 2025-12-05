import 'package:expense_wise/data/enums/expense_category_enum.dart';
import 'package:expense_wise/data/model/expense_model.dart';
import 'package:expense_wise/data/repository/expense_data_repository_impl.dart';
import 'package:expense_wise/data/service/ui_helper_service_impl.dart';
import 'package:expense_wise/domain/repository/expense_data_repository.dart';
import 'package:expense_wise/domain/service/ui_helper_service.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

class HomeScreenState {
  final List<ExpenseModel> allExpenses;
  final Map<String, List<ExpenseModel>> groupedExpenses;
  final num totalSpent;
  final bool isLoading;
  final String searchQuery;
  final Set<ExpenseCategory> selectedCategories;

  HomeScreenState({
    required this.allExpenses,
    required this.isLoading,
    required this.totalSpent,
    required this.groupedExpenses,
    required this.searchQuery,
    required this.selectedCategories,
  });

  HomeScreenState copyWith({
    List<ExpenseModel>? allExpenses,
    bool? isLoading,
    num? totalSpent,
    Map<String, List<ExpenseModel>>? groupedExpenses,
    Set<ExpenseCategory>? selectedCategories,
    String? searchQuery,
  }) {
    return HomeScreenState(
      allExpenses: allExpenses ?? this.allExpenses,
      isLoading: isLoading ?? this.isLoading,
      totalSpent: totalSpent ?? this.totalSpent,
      groupedExpenses: groupedExpenses ?? this.groupedExpenses,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategories: selectedCategories ?? this.selectedCategories,
    );
  }

  HomeScreenState.initial()
    : this(
        allExpenses: [],
        isLoading: true,
        totalSpent: 0,
        groupedExpenses: {},
        selectedCategories: {},
        searchQuery: '',
      );
}

class HomeScreenViewModel extends StateNotifier<HomeScreenState> {
  final ExpenseDataRepository expenseDataRepository;
  final UIHelperService uiHelperService;

  HomeScreenViewModel({
    required this.expenseDataRepository,
    required this.uiHelperService,
  }) : super(HomeScreenState.initial()) {
    fetchAllExpenses();
  }

  Map<String, List<ExpenseModel>> groupExpenses({
    required List<ExpenseModel> expenseList,
  }) {
    final filteredExpenses = expenseList.where((expense) {
      final matchesSearch = expense.title.toLowerCase().contains(state.searchQuery.toLowerCase());

      // If set is empty, show all. Otherwise, check if category is in the set.
      final matchesCategory = state.selectedCategories.isEmpty || state.selectedCategories.contains(expense.category);

      return matchesSearch && matchesCategory;
    }).toList();

    Map<String, List<ExpenseModel>> groupedExpenses = {};
    for (var expense in filteredExpenses) {
      String monthYear = DateFormat('MMMM yyyy').format(expense.dateTime);
      if (!groupedExpenses.containsKey(monthYear)) {
        groupedExpenses[monthYear] = [];
      }
      groupedExpenses[monthYear]!.add(expense);
    }
    return groupedExpenses;
  }

  void fetchAllExpenses() async {
    state = state.copyWith(isLoading: true);
    final response = await expenseDataRepository.getAllExpenses();

    response.fold(
      ifLeft: (failure) {
        state = state.copyWith(
          isLoading: false,
          allExpenses: [],
          groupedExpenses: {},
        );
        uiHelperService.showSnackBar(msg: failure.errorMsg);
      },
      ifRight: (expenseList) {
        DateTime now = DateTime.now();
        num totalSpent = expenseList
            .where((e) => e.dateTime.year == now.year && e.dateTime.month == now.month)
            .fold(0, (sum, item) => sum + item.amount);
        final groupedExpenses = groupExpenses(expenseList: expenseList);
        state = state.copyWith(
          allExpenses: expenseList,
          groupedExpenses: groupedExpenses,
          isLoading: false,
          totalSpent: totalSpent,
        );
      },
    );
  }

  void search({String? searchQuery, Set<ExpenseCategory>? selectedCategories}){
    state = state.copyWith(searchQuery: searchQuery,selectedCategories: selectedCategories);
    final groupedExpenses = groupExpenses(expenseList: state.allExpenses);
    state = state.copyWith(groupedExpenses: groupedExpenses);
  }
}

final homeScreenViewModelProvider =
    StateNotifierProvider<HomeScreenViewModel, HomeScreenState>(
      (ref) => HomeScreenViewModel(
        expenseDataRepository: ref.read(expenseDataRepositoryProvider),
        uiHelperService: ref.read(uiServiceHelperProvider),
      ),
    );
