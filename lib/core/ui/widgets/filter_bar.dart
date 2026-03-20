import 'package:flutter/material.dart';
import '../../ui/responsive.dart';

class FilterBar extends StatelessWidget {
  final List<Widget> children;
  final Widget? trailing;

  const FilterBar({
    super.key,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isMob = isMobile(context);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMob
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: children,
                ),
                if (trailing != null) ...[
                  const SizedBox(height: 16),
                  trailing!,
                ]
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: children,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 16),
                  trailing!,
                ]
              ],
            ),
    );
  }
}
