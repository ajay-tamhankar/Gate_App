import 'package:flutter/material.dart';

import '../theme.dart';

/// Rainbow "S-themed" shimmer skeleton. A subtle pink/orange sweep slides
/// across a surface tinted to match the current theme.
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final base = isDark
        ? VistarTokens.darkSurface2
        : theme.colorScheme.onSurface.withValues(alpha: 0.05);
    final radius = widget.borderRadius ?? BorderRadius.circular(10);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        // LayoutBuilder gives us the resolved width even when callers pass
        // `double.infinity` — without it, Positioned(width: infinity) and the
        // NaN-producing `-infinity + infinity` translation spam
        // "BoxConstraints forces an infinite width" on every animation tick
        // and freeze the UI.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final resolvedWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 0.0;
            return ColoredBox(
              color: base,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned(
                        left: -resolvedWidth + (t * (resolvedWidth * 2.4)),
                        top: 0,
                        bottom: 0,
                        width: resolvedWidth,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                VistarTokens.pink.withValues(alpha: 0.16),
                                VistarTokens.orange.withValues(alpha: 0.12),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.45, 0.65, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
