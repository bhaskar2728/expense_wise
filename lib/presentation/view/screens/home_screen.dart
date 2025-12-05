import 'package:expense_wise/core/app_colors.dart';
import 'package:expense_wise/presentation/view/screens/add_expense_screen.dart';
import 'package:expense_wise/presentation/view/screens/coming_soon_screen.dart';
import 'package:expense_wise/presentation/view/screens/expense_screen.dart';
import 'package:expense_wise/presentation/view/widgets/app_bar.dart';
import 'package:expense_wise/presentation/view/widgets/bottom_nav_bar_widget.dart';
import 'package:expense_wise/presentation/view/widgets/expense_list_widget.dart';
import 'package:expense_wise/presentation/view/widgets/search_bar_filter_icon_widget.dart';
import 'package:expense_wise/presentation/viewmodel/home_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: selectedTabIndex,
        children: [
          ExpenseScreen(),
          const ComingSoonScreen(title: 'Statistics', icon: Icons.bar_chart),
          const ComingSoonScreen(title: 'History', icon: Icons.history),
          const ComingSoonScreen(title: 'Profile', icon: Icons.person),
        ],
      ),
      floatingActionButton: selectedTabIndex == 0 ?FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddOrUpdateExpenseScreen())).then((value){
            ref.read(homeScreenViewModelProvider.notifier).fetchAllExpenses();
          });
        },
        backgroundColor: AppColors.primaryRed,
        icon: const Icon(Icons.receipt_long, color: Colors.white),
        label: const Text('Add expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ) : null,
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: selectedTabIndex,
        onIndexChanged: (index){
          setState(()=>selectedTabIndex = index);
        },
      ),
    );
  }
}
