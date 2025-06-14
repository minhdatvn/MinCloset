// file: lib/screens/item_detail_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';

class ItemDetailPage extends StatefulWidget {
  final ClothingItem item;
  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late ClothingItem _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

  void _handleFieldUpdate(Map<String, dynamic> newValues) async {
    // Tạo một bản sao của item hiện tại và cập nhật các giá trị mới
    final currentMap = _currentItem.toMap();
    currentMap.addAll(newValues);
    final updatedItem = ClothingItem.fromMap(currentMap);

    setState(() {
      _currentItem = updatedItem;
    });
    await DatabaseHelper.instance.updateItem(updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentItem.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(File(_currentItem.imagePath), height: MediaQuery.of(context).size.height * 0.4, width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Text(_currentItem.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),

            MultiSelectChipField(
              label: 'Mùa',
              allOptions: AppOptions.seasons,
              initialSelections: (_currentItem.season?.split(', ').where((s) => s.isNotEmpty).toSet() ?? {}),
              onSelectionChanged: (newSelections) => _handleFieldUpdate({'season': newSelections.join(', ')}),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            MultiSelectChipField(
              label: 'Mục đích',
              allOptions: AppOptions.occasions,
              initialSelections: (_currentItem.occasion?.split(', ').where((s) => s.isNotEmpty).toSet() ?? {}),
              onSelectionChanged: (newSelections) => _handleFieldUpdate({'occasion': newSelections.join(', ')}),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            MultiSelectChipField(
              label: 'Chất liệu',
              allOptions: AppOptions.materials,
              initialSelections: (_currentItem.material?.split(', ').where((s) => s.isNotEmpty).toSet() ?? {}),
              onSelectionChanged: (newSelections) => _handleFieldUpdate({'material': newSelections.join(', ')}),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            MultiSelectChipField(
              label: 'Họa tiết',
              allOptions: AppOptions.patterns,
              initialSelections: (_currentItem.pattern?.split(', ').where((s) => s.isNotEmpty).toSet() ?? {}),
              onSelectionChanged: (newSelections) => _handleFieldUpdate({'pattern': newSelections.join(', ')}),
            ),
          ],
        ),
      ),
    );
  }
}