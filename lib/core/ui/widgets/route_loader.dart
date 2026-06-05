import 'dart:ui';

import 'package:flutter/material.dart';

import 's_orbit_loader.dart';

/// Full-page route-change overlay — a translucent backdrop with a breathing
/// S mark. Use during navigation transitions or heavy in-page reloads.
class RouteLoaderOverlay extends StatelessWidget {
  final bool visible;
  final String? label;

  const RouteLoaderOverlay({
    super.key,
    required this.visible,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: visible
          ? Positioned.fill(
              key: const ValueKey('route-loader-on'),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: ColoredBox(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xCC070611)
                      : const Color(0xCCFAF8FE),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SOrbitLoader.small(),
                        if (label != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            label!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('route-loader-off')),
    );
  }
}
