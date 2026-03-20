import 'package:flutter/material.dart';

import '../theme.dart';

class DashboardChart extends StatelessWidget {
  final String title;
  final List<ChartBarData> data;
  final double height;
  final bool animate;

  const DashboardChart({
    super.key,
    required this.title,
    required this.data,
    this.height = 200,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = data.fold<double>(
        0.0, (val, item) => item.value > val ? item.value : val);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: height,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const minBarWidth = 32.0;
                  const barSpacing = 16.0;
                  final rawBarWidth = (constraints.maxWidth -
                          (barSpacing * (data.length - 1))) /
                      data.length;
                  final barWidth =
                      rawBarWidth < minBarWidth ? minBarWidth : rawBarWidth;
                  final contentWidth = (barWidth * data.length) +
                      (barSpacing * (data.length - 1));
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: contentWidth < constraints.maxWidth
                            ? constraints.maxWidth
                            : contentWidth,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (int i = 0; i < data.length; i++) ...[
                            _buildBar(
                                context, data[i], maxVal, height, barWidth),
                            if (i != data.length - 1)
                              const SizedBox(width: barSpacing),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(
    BuildContext context,
    ChartBarData item,
    double maxVal,
    double height,
    double barWidth,
  ) {
    final fillPercent = maxVal == 0 ? 0.0 : item.value / maxVal;
    const reservedSpace = 70.0; // space for text + label
    final barHeight = fillPercent * (height - reservedSpace);
    return Tooltip(
      message: '${item.label}: ${item.value}',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            item.value.toStringAsFixed(0),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: barHeight),
            duration: Duration(milliseconds: animate ? 800 : 0),
            curve: Curves.easeOutQuart,
            builder: (context, val, child) {
              return Container(
                width: barWidth,
                height: val.clamp(0.0, height),
                decoration: BoxDecoration(
                  color: item.color ?? AppTheme.primaryBlue,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            item.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class ChartBarData {
  final String label;
  final double value;
  final Color? color;

  const ChartBarData({
    required this.label,
    required this.value,
    this.color,
  });
}
