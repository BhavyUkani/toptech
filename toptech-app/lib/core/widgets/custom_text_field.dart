import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool forceWhite;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.forceWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isMultiLine = maxLines != null && maxLines! > 1;

    // Resolve colors: if forceWhite override everything to white
    final textColor = forceWhite ? Colors.white : (isDark ? Colors.white : Colors.black87);
    final labelColor = forceWhite ? Colors.white70 : (isDark ? Colors.white70 : Colors.black54);
    final hintColor = forceWhite ? Colors.white38 : (isDark ? Colors.white30 : Colors.black38);
    final iconColor = forceWhite ? Colors.white70 : (isDark ? Colors.white70 : Colors.black54);
    final borderColor = forceWhite ? Colors.white38 : (isDark ? Colors.white30 : Colors.black26);
    final focusedBorderColor = forceWhite
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF1C2452));

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: labelColor,
          fontSize: 13,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: iconColor,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: isMultiLine ? 16 : 12,
        ),
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusedBorderColor, width: 1.8),
        ),
      ),
    );
  }
}
