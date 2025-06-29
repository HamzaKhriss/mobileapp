import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum NotificationType {
  success,
  error,
  warning,
  info,
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Show a snackbar notification
  static void showSnackBar(
    BuildContext context,
    String message, {
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Clear any existing snackbars
    scaffoldMessenger.clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIconForType(type),
            color: Colors.white,
            size: 20,
          ),
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
      backgroundColor: _getColorForType(type),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onActionPressed ?? () {},
            )
          : null,
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }

  // Show a booking confirmation notification
  static void showBookingConfirmation(
    BuildContext context, {
    required String listingTitle,
    required String date,
    required String time,
    required int participants,
    required double totalPrice,
  }) {
    showSnackBar(
      context,
      'Booking confirmed for $listingTitle on $date at $time',
      type: NotificationType.success,
      duration: const Duration(seconds: 6),
      actionLabel: 'View',
      onActionPressed: () {
        // Navigate to bookings page using GoRouter
        context.goNamed('profile');
      },
    );
  }

  // Show booking error notification
  static void showBookingError(
    BuildContext context,
    String error,
  ) {
    showSnackBar(
      context,
      'Booking failed: $error',
      type: NotificationType.error,
      duration: const Duration(seconds: 5),
      actionLabel: 'Retry',
    );
  }

  // Show in-app notification dialog
  static void showNotificationDialog(
    BuildContext context, {
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    String? primaryButtonText,
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                _getIconForType(type),
                color: _getColorForType(type),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            if (secondaryButtonText != null)
              TextButton(
                onPressed:
                    onSecondaryPressed ?? () => Navigator.of(context).pop(),
                child: Text(secondaryButtonText),
              ),
            ElevatedButton(
              onPressed: onPrimaryPressed ?? () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getColorForType(type),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(primaryButtonText ?? 'OK'),
            ),
          ],
        );
      },
    );
  }

  // Helper methods
  static IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }

  static Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFF4CAF50);
      case NotificationType.error:
        return const Color(0xFFF44336);
      case NotificationType.warning:
        return const Color(0xFFFF9800);
      case NotificationType.info:
        return const Color(0xFF2196F3);
    }
  }
}
