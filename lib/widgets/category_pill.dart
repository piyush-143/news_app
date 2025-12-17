import 'package:flutter/material.dart';

class CategoryPill extends StatelessWidget {
  final String text;
  final bool isSelected;

  const CategoryPill({super.key, required this.text, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isSelected
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? const Color(0xFF1E1E1E) : Colors.white);

    final textColor = isSelected
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? Colors.white : Colors.black);

    return Container(
      margin: const EdgeInsets.only(right: 5, left: 5, bottom: 0),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: isSelected
            ? null
            : Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}
