import 'package:flutter/material.dart';

import 'package:bloomshop/core/constants/app_colors.dart';

/// Shows a floating snackbar (replacing any current one).
void showAppSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  showAppSnackBarOn(
    ScaffoldMessenger.of(context),
    message,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}

/// Same as [showAppSnackBar] but takes a messenger captured earlier. Use it
/// when the calling widget may be removed from the tree before the snackbar
/// is shown (e.g. after deleting a list item).
void showAppSnackBarOn(
  ScaffoldMessengerState messenger,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: AppColors.softPink,
                onPressed: onAction ?? () {},
              ),
      ),
    );
}
