import 'package:flutter/material.dart';

import 'app_loader.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? barrierColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.barrierColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: isLoading ? 1 : 0,
                child: ColoredBox(
                  color: barrierColor ?? Colors.black.withValues(alpha: 0.35),
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
                        child: AppLoader(size: 36, label: message),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
