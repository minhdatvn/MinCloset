// lib/widgets/stats_pie_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatsPieChart extends StatefulWidget {
  final String title;
  final Map<String, int> dataMap;
  final bool showChartTitle;
  final List<Color>? colors;
  final double? size; // <<< THÊM MỚI: Tham số để nhận kích thước từ bên ngoài

  const StatsPieChart({
    super.key,
    required this.title,
    required this.dataMap,
    this.showChartTitle = true,
    this.colors,
    this.size, // <<< THÊM MỚI
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
        centerSpaceRadius: widget.size != null ? (widget.size! * 0.25) : 25, // Tính toán lỗ trống dựa trên size
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
    final total = widget.dataMap.values.fold(0, (sum, item) => sum + item);
    final colors = widget.colors ?? _defaultChartColors;
    int index = 0;

    // <<< THAY ĐỔI LỚN: Bán kính giờ đây được tính toán động >>>
    // Nếu có size từ bên ngoài, tính toán bán kính dựa trên size đó.
    // Nếu không, dùng giá trị mặc định.
    final double baseRadius = widget.size != null ? (widget.size! / 2) * 0.8 : 50.0;
    final double touchedRadius = widget.size != null ? (widget.size! / 2) * 0.9 : 60.0;
    final double titleFontSize = widget.size != null ? (widget.size! / 8) : 14.0;

    return widget.dataMap.entries.map((entry) {
      final isTouched = index == touchedIndex;
      final radius = isTouched ? touchedRadius : baseRadius;
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
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();
  }
}