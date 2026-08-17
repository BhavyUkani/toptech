import 'package:flutter/material.dart';

class AppSnackBar {
  AppSnackBar._();

  /// Global key to access ScaffoldMessenger from anywhere in the app without BuildContext
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message, [BuildContext? context]) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF10B981),
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showError(String message, [BuildContext? context]) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFFEF4444),
      icon: Icons.error_outline_rounded,
    );
  }

  static void showInfo(String message, [BuildContext? context]) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF3B82F6),
      icon: Icons.info_outline_rounded,
    );
  }

  static void showWarning(String message, [BuildContext? context]) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFFF59E0B),
      icon: Icons.warning_amber_rounded,
    );
  }

  static void _show({
    BuildContext? context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );

    if (context != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    } else {
      final state = messengerKey.currentState;
      state?.hideCurrentSnackBar();
      state?.showSnackBar(snackBar);
    }
  }
}
