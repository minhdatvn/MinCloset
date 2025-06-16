// lib/widgets/stats_pie_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatsPieChart extends StatefulWidget {
  final String title;
  final Map<String, int> dataMap;

  const StatsPieChart({
    super.key,
    required this.title,
    required this.dataMap,
  });

  @override
  State<StatsPieChart> createState() => _StatsPieChartState();
}

class _StatsPieChartState extends State<StatsPieChart> {
  int? touchedIndex;

  // Danh sách các màu đẹp mắt để biểu đồ không bị đơn điệu
  final List<Color> _chartColors = const [
    Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple,
    Colors.yellow, Colors.cyan, Colors.pink, Colors.teal, Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.dataMap.isEmpty) {
      return const SizedBox.shrink(); // Không hiển thị gì nếu không có dữ liệu
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        elevation: 0,
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _buildChartSections(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections() {
    final total = widget.dataMap.values.fold(0, (sum, item) => sum + item);
    int colorIndex = 0;

    return widget.dataMap.entries.map((entry) {
      final isTouched = widget.dataMap.keys.toList().indexOf(entry.key) == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final percentage = (entry.value / total * 100);
      final color = _chartColors[colorIndex % _chartColors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();
  }
}