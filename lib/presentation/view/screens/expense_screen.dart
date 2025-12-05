import 'package:expense_wise/presentation/view/widgets/app_bar.dart';
import 'package:expense_wise/presentation/view/widgets/expense_list_widget.dart';
import 'package:expense_wise/presentation/view/widgets/search_bar_filter_icon_widget.dart';
import 'package:flutter/material.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        CustomAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                SearchBarFilterIconWidget(),
                const SizedBox(height: 20),
                ExpenseListWidget()
              ],
            ),
          ),
        ),
      ],
    );
  }
}
