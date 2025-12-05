import 'package:expense_wise/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final Color? color;
  final String hintText;
  final bool isAmount;

  const InputField({
    super.key,
    required this.controller,
    required this.icon,
    this.color,
    required this.hintText,
    required this.isAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color ?? Colors.black, size: 28,),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            validator: isAmount ? (value) {
              if (value == null || value.isEmpty) return 'Enter an amount';
              if (double.tryParse(value) == null) return 'Invalid number';
              return null;
            } : (value) {
              if (value == null || value.isEmpty) return 'Enter some description';
              return null;
            } ,
            controller: controller,
            keyboardType: isAmount
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            inputFormatters: isAmount
                ? [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ]
                : [],
            style: TextStyle(fontSize: isAmount ? 24 : 15),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: isAmount ? 24 : 16,
                fontWeight: isAmount ? FontWeight.bold : FontWeight.w400
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 0.5,
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.inputUnderline,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
