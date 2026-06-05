import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme_controller.dart';

/// Icon button that cycles through ThemeMode (system → light → dark → system).
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);

    final (icon, tooltip) = switch (mode) {
      ThemeMode.light => (Icons.light_mode_rounded, 'Theme: light (click for dark)'),
      ThemeMode.dark => (Icons.dark_mode_rounded, 'Theme: dark (click for system)'),
      ThemeMode.system =>
        (Icons.brightness_auto_rounded, 'Theme: system (click for light)'),
    };

    return IconButton(
      tooltip: tooltip,
      onPressed: controller.cycle,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) => RotationTransition(
          turns: anim,
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Icon(icon, key: ValueKey(icon)),
      ),
    );
  }
}
