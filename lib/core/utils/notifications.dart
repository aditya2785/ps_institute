import 'package:flutter/material.dart';
import 'package:ps_institute/config/palette.dart';

class AppNotifications {
  /// Global messenger key (safe snackbar)
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // =====================================================
  // BACKWARD-COMPATIBLE METHODS (KEEP OLD API WORKING)
  // =====================================================

  static void showSuccess(BuildContext context, String message) {
    _show(message, Palette.success);
  }

  static void showError(BuildContext context, String message) {
    _show(message, Palette.error);
  }

  static void showWarning(BuildContext context, String message) {
    _show(message, Palette.warning);
  }

  static void showInfo(BuildContext context, String message) {
    _show(message, Palette.secondary);
  }

  // =====================================================
  // INTERNAL SAFE SNACKBAR (NO CONTEXT USED)
  // =====================================================

  static void _show(String message, Color background) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // =====================================================
  // LOADING DIALOG (SAFE)
  // =====================================================

  static void showLoading(BuildContext context,
      {String message = "Loading..."}) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Palette.primary),
              const SizedBox(width: 20),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void hideLoading(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
