import 'package:expense_wise/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const ComingSoonScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
            title,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Don't show back button on tabs
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 64, color: AppColors.primaryRed),
              ),
              const SizedBox(height: 32),
              Text(
                'Coming Soon',
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We are currently working hard to bring this feature to life in the next update.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: AppColors.greyText, fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}