import 'package:flutter/material.dart';

import 'app_loader.dart';

/// Runs [task] while showing a non-dismissible modal progress dialog.
///
/// The dialog is closed automatically before the result is returned, so callers
/// can safely show snackbars or push new routes afterwards.
///
/// Returns the value produced by [task]. If [task] throws, the dialog is
/// closed and the exception is rethrown.
Future<T> runWithProgressDialog<T>(
  BuildContext context,
  Future<T> Function() task, {
  required String label,
}) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 24,
              ),
              child: AppLoader(size: 36, label: label),
            ),
          ),
        ),
      ),
    ),
  );

  try {
    return await task();
  } finally {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
