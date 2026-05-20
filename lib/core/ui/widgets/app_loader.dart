import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final String? label;

  const AppLoader({
    super.key,
    this.size = 32,
    this.strokeWidth = 3,
    this.color,
    this.label,
  });

  const AppLoader.small({super.key, this.color, this.label})
      : size = 18,
        strokeWidth = 2;

  const AppLoader.button({super.key, this.color})
      : size = 20,
        strokeWidth = 2.4,
        label = null;

  @override
  Widget build(BuildContext context) {
    final spinnerColor = color ?? Theme.of(context).colorScheme.primary;
    final spinner = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
      ),
    );

    if (label == null) return spinner;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        spinner,
        const SizedBox(height: 12),
        Text(
          label!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class AppLoaderCentered extends StatelessWidget {
  final String? label;
  final double size;

  const AppLoaderCentered({super.key, this.label, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Center(child: AppLoader(size: size, label: label));
  }
}
