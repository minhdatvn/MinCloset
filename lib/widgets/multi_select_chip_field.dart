// lib/widgets/multi_select_chip_field.dart
import 'package:flutter/material.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/helpers/l10n_helper.dart';
import 'package:mincloset/helpers/context_extensions.dart';

class MultiSelectChipField extends StatefulWidget {
  final String label;
  final dynamic allOptions;
  final Set<String> initialSelections;
  final Function(Set<String>) onSelectionChanged;
  final Widget? labelAction;

  const MultiSelectChipField({
    super.key,
    required this.label,
    required this.allOptions,
    required this.initialSelections,
    required this.onSelectionChanged,
    this.labelAction,
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
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Row(
              children: [
                Text(widget.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (widget.labelAction != null) ...[
                  const SizedBox(width: 4),
                  widget.labelAction!,
                ],
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
    final l10n = context.l10n;
    if (_selectedOptions.isEmpty) {
      return Text(l10n.itemDetail_form_colorNotYet, style: TextStyle(fontSize: 16, color: Colors.grey.shade600));
    }
    if (isColorSelector && widget.allOptions is Map<String, Color>) {
      final colorMap = widget.allOptions as Map<String, Color>;
      const maxCircles = 5;
      final extraCount = _selectedOptions.length - maxCircles;
      
      final visibleColors = _selectedOptions.take(maxCircles).toList();

      return Row(
        mainAxisSize: MainAxisSize.min,
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
    final translatedOptions = _selectedOptions.map((key) => translateAppOption(key, l10n)).join(', ');

    return Flexible(
      child: Text(
        translatedOptions, // Sử dụng chuỗi đã dịch
        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildColorGrid() {
    final colorMap = widget.allOptions as Map<String, Color>;
    final theme = Theme.of(context);

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
          child: GestureDetector(
            onTap: () => _handleSelection(name),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtherOptionsWrap() {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.center,
      children: (widget.allOptions as Iterable).map((option) {
        final String key = option is OptionWithImage ? option.name : option as String;
        final isSelected = _selectedOptions.contains(key);
        final String labelText = translateAppOption(key, l10n);
        
        final avatar = option is OptionWithImage
          ? CircleAvatar(
              backgroundColor: Colors.transparent,
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
          label: Text(
            labelText,
            style: TextStyle(
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => _handleSelection(key),
          showCheckmark: false,
          backgroundColor: Colors.white,
          selectedColor: theme.colorScheme.primary,
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              width: 1,
            ),
          ),
        );
      }).toList(),
    );
  }
}