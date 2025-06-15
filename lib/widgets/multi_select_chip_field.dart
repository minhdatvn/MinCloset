// lib/widgets/multi_select_chip_field.dart
import 'package:flutter/material.dart';
import 'package:mincloset/constants/app_options.dart';

class MultiSelectChipField extends StatefulWidget {
  final String label;
  final List<dynamic> allOptions;
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
  Set<String> _selectedOptions = {};

  // <<< LỖI ĐƯỢC SỬA TẠI ĐÂY
  @override
  void initState() {
    super.initState();
    // Gán giá trị được truyền từ widget cha vào trạng thái nội bộ
    // ngay khi widget được tạo lần đầu tiên.
    _selectedOptions = widget.initialSelections;
  }

  @override
  void didUpdateWidget(covariant MultiSelectChipField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelections != widget.initialSelections) {
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
    final displayValue = _selectedOptions.isEmpty ? 'Chưa có' : _selectedOptions.join(', ');

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(child: Text(displayValue, style: TextStyle(fontSize: 16, color: Colors.grey.shade600), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: widget.allOptions.map((option) {
                final String name = option is OptionWithImage ? option.name : option;
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
            ),
          ),
      ],
    );
  }
}