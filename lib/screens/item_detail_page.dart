// lib/screens/item_detail_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/item_detail_notifier.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';

class ItemDetailPage extends ConsumerWidget {
  final ClothingItem item;
  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemProvider = itemDetailProvider(item);
    final currentItem = ref.watch(itemProvider);
    final notifier = ref.read(itemProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentItem.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => AddItemScreen(itemToEdit: currentItem)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xác nhận xóa'),
                  content: Text('Bạn có chắc chắn muốn xóa món đồ "${currentItem.name}" không?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Xóa'),
                    ),
                  ],
                )
              );
              
              if (confirmed == true) {
                await notifier.deleteItem();
                if (context.mounted) {
                  Navigator.of(context).pop(true); 
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(File(currentItem.imagePath), height: MediaQuery.of(context).size.height * 0.4, width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Text(currentItem.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),

            // <<< THÊM WIDGET CHO MÀU SẮC TẠI ĐÂY
            MultiSelectChipField(
              label: 'Màu sắc',
              allOptions: AppOptions.colors,
              initialSelections: currentItem.color.split(', ').where((s) => s.isNotEmpty).toSet(),
              onSelectionChanged: (newSelections) => notifier.updateField(color: newSelections),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            
            MultiSelectChipField(
              label: 'Mùa',
              allOptions: AppOptions.seasons,
              initialSelections: currentItem.season?.split(', ').where((s) => s.isNotEmpty).toSet() ?? {},
              onSelectionChanged: (newSelections) => notifier.updateField(season: newSelections),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            MultiSelectChipField(
              label: 'Mục đích',
              allOptions: AppOptions.occasions,
              initialSelections: currentItem.occasion?.split(', ').where((s) => s.isNotEmpty).toSet() ?? {},
              onSelectionChanged: (newSelections) => notifier.updateField(occasion: newSelections),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            MultiSelectChipField(
              label: 'Chất liệu',
              allOptions: AppOptions.materials,
              initialSelections: currentItem.material?.split(', ').where((s) => s.isNotEmpty).toSet() ?? {},
              onSelectionChanged: (newSelections) => notifier.updateField(material: newSelections),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),

            MultiSelectChipField(
              label: 'Họa tiết',
              allOptions: AppOptions.patterns,
              initialSelections: currentItem.pattern?.split(', ').where((s) => s.isNotEmpty).toSet() ?? {},
              onSelectionChanged: (newSelections) => notifier.updateField(pattern: newSelections),
            ),
          ],
        ),
      ),
    );
  }
}