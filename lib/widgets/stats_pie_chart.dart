// lib/widgets/stats_pie_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatsPieChart extends StatefulWidget {
  final String title;
  final Map<String, int> dataMap;
  final bool showChartTitle;
  final List<Color>? colors;
  final double? size;

  const StatsPieChart({
    super.key,
    required this.title,
    required this.dataMap,
    this.showChartTitle = true,
    this.colors,
    this.size,
  });

  @override
  State<StatsPieChart> createState() => _StatsPieChartState();
}

class _StatsPieChartState extends State<StatsPieChart> {
  int? touchedIndex;

  final List<Color> _defaultChartColors = const [
    Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple,
    Colors.yellow, Colors.cyan, Colors.pink, Colors.teal, Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.dataMap.isEmpty) {
      return const SizedBox.shrink();
    }

    final pieChart = PieChart(
      PieChartData(
        // <<< THAY ĐỔI 1: XOAY BIỂU ĐỒ ĐỂ BẮT ĐẦU TỪ HƯỚNG 12 GIỜ >>>
        startDegreeOffset: -90,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: widget.size != null ? (widget.size! * 0.3) : 25,
        sections: _buildChartSections(),
      ),
    );

    if (!widget.showChartTitle) {
      return pieChart;
    }
    
    return Column(
      children: [
        Text(
          widget.title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(child: pieChart),
      ],
    );
  }

  List<PieChartSectionData> _buildChartSections() {
    // <<< THAY ĐỔI 2: SẮP XẾP DỮ LIỆU TRƯỚC KHI VẼ >>>
    // Chuyển map thành list và sắp xếp theo giá trị giảm dần
    final sortedEntries = widget.dataMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = widget.dataMap.values.fold(0, (sum, item) => sum + item);
    final colors = widget.colors ?? _defaultChartColors;
    int index = 0;

    // Duyệt qua danh sách đã được sắp xếp
    return sortedEntries.map((entry) {
      final isTouched = index == touchedIndex;
      
      final double radius = isTouched 
          ? (widget.size! / 2 * 1.0) 
          : (widget.size! / 2 * 0.85);
      
      final double titleFontSize = isTouched 
          ? (widget.size! / 7)
          : (widget.size! / 9);

      final percentage = (entry.value / total * 100);
      final color = colors[index % colors.length];
      index++;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: isTouched ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    }).toList();
  }
}