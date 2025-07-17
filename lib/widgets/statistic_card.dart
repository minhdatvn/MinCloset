// lib/widgets/statistic_card.dart
import 'package:flutter/material.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/helpers/l10n_helper.dart';
import 'package:mincloset/theme/app_theme.dart';
import 'package:mincloset/widgets/stats_pie_chart.dart';

class StatisticCard extends StatelessWidget {
  final String title;
  final Map<String, int> dataMap;
  final List<Color>? specificColors;

  const StatisticCard({
    super.key,
    required this.title,
    required this.dataMap,
    this.specificColors,
  });

  String _truncateText(String text, int maxLength) {
    return text.length <= maxLength ? text : '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final totalValue = dataMap.values.fold(0, (sum, item) => sum + item);
    if (totalValue == 0) return const SizedBox.shrink();

    final sortedEntries = dataMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntries = sortedEntries.take(4);

    const double chartSize = 90;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: chartSize,
                      height: chartSize,
                      child: StatsPieChart(
                        title: '',
                        dataMap: dataMap,
                        showChartTitle: false,
                        colors: specificColors ?? AppChartColors.defaultChartColors,
                        size: chartSize,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: topEntries.map((entry) {
                        final percentage = (entry.value / totalValue * 100);
                        final color = (specificColors ?? AppChartColors.defaultChartColors)[sortedEntries.indexOf(entry) % (specificColors ?? AppChartColors.defaultChartColors).length];
                        final String translatedName = translateAppOption(entry.key, l10n);
                        final truncatedName = _truncateText(translatedName, 10);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3.0))),
                              const SizedBox(width: 8),
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    TextSpan(text: '$truncatedName '),
                                    TextSpan(
                                      text: '${percentage.toStringAsFixed(0)}%',
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}