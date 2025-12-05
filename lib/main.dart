import 'package:expense_wise/core/app_colors.dart';
import 'package:expense_wise/core/service/navigation_service.dart';
import 'package:expense_wise/presentation/view/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: NavigationService.instance.navigationKey,
      theme: ThemeData(
        // Set Poppins as the default font for the entire app
        textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
        primaryColor: AppColors.primaryRed,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryRed),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
