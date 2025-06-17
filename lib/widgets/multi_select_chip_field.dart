// lib/widgets/multi_select_chip_field.dart
import 'package:flutter/material.dart';
import 'package:mincloset/constants/app_options.dart';

class MultiSelectChipField extends StatefulWidget {
  final String label;
  final dynamic allOptions;
  final Set<String> initialSelections;
  final Function(Set<String>) onSelectionChanged;

  const MultiSelectChipField({
    super.key,
    required this.label,
    required this.allOptions,
    required this.initialSelections,
    required this.onSelectionChanged,
  });

  @override
  State<MultiSelectChipField> createState() => _MultiSelectChipFieldState();
}

class _MultiSelectChipFieldState extends State<MultiSelectChipField> {
  bool _isExpanded = false;
  late Set<String> _selectedOptions;

  @override
  void initState() {
    super.initState();
    _selectedOptions = widget.initialSelections;
  }

  @override
  void didUpdateWidget(covariant MultiSelectChipField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelections != oldWidget.initialSelections) {
      setState(() {
        _selectedOptions = widget.initialSelections;
      });
    }
  }

  void _handleSelection(String optionName) {
    final newSelections = Set<String>.from(_selectedOptions);
    if (newSelections.contains(optionName)) {
      newSelections.remove(optionName);
    } else {
      newSelections.add(optionName);
    }
    setState(() {
      _selectedOptions = newSelections;
    });
    widget.onSelectionChanged(newSelections);
  }

  @override
  Widget build(BuildContext context) {
    final bool isColorSelector = widget.allOptions is Map<String, Color>;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              children: [
                Text(widget.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16), // Thêm khoảng cách nhỏ
                // <<< THAY ĐỔI Ở ĐÂY: Dùng Expanded để đẩy cụm tóm tắt về bên phải
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end, // Căn phải
                    children: [
                      _buildSummaryView(isColorSelector),
                      const SizedBox(width: 4),
                      Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: isColorSelector
                ? _buildColorGrid()
                : _buildOtherOptionsWrap(),
          ),
      ],
    );
  }

  Widget _buildSummaryView(bool isColorSelector) {
    if (_selectedOptions.isEmpty) {
      return Text('Chưa có', style: TextStyle(fontSize: 16, color: Colors.grey.shade600));
    }
    if (isColorSelector && widget.allOptions is Map<String, Color>) {
      final colorMap = widget.allOptions as Map<String, Color>;
      const maxCircles = 5;
      final extraCount = _selectedOptions.length - maxCircles;
      
      final visibleColors = _selectedOptions.take(maxCircles).toList();

      return Row(
        mainAxisSize: MainAxisSize.min, // Để Row chỉ chiếm không gian cần thiết
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ...visibleColors.map((name) {
            final color = colorMap[name] ?? Colors.transparent;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400, width: 0.5),
              ),
            );
          }),
          if (extraCount > 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              width: 18,
              height: 18,
              decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
              child: Center(child: Text('+$extraCount', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54))),
            )
        ],
      );
    }
    // Bọc Text trong Flexible để nó không đẩy các widget khác
    return Flexible(
      child: Text(
        _selectedOptions.join(', '),
        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildColorGrid() {
    final colorMap = widget.allOptions as Map<String, Color>;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
      ),
      itemCount: colorMap.length,
      itemBuilder: (context, index) {
        final entry = colorMap.entries.elementAt(index);
        final name = entry.key;
        final color = entry.value;
        final isSelected = _selectedOptions.contains(name);

        return Tooltip(
          message: name,
          showDuration: const Duration(seconds: 2),
          child: GestureDetector(
            onTap: () => _handleSelection(name),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtherOptionsWrap() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.center, // Căn giữa các chip
      children: (widget.allOptions as Iterable).map((option) {
        final String name = option is OptionWithImage ? option.name : option as String;
        final Widget? avatar = option is OptionWithImage
          ? CircleAvatar(
              child: Image.asset(
                option.imagePath,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.category, size: 18, color: Colors.grey);
                },
              ),
            )
          : null;

        return FilterChip(
          avatar: avatar,
          label: Text(name),
          selected: _selectedOptions.contains(name),
          onSelected: (_) => _handleSelection(name),
          selectedColor: Colors.deepPurple.withAlpha(51),
          checkmarkColor: Colors.deepPurple,
        );
      }).toList(),
    );
  }
}