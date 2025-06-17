// lib/screens/item_detail_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/item_detail_notifier.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';

class ItemDetailPage extends ConsumerStatefulWidget {
  final ClothingItem item;
  const ItemDetailPage({super.key, required this.item});

  @override
  ConsumerState<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends ConsumerState<ItemDetailPage> {
  late final TextEditingController _nameController;
  final FocusNode _nameFocusNode = FocusNode();
  bool _isEditingName = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _nameFocusNode.addListener(() {
      if (mounted && _isEditingName != _nameFocusNode.hasFocus) {
        setState(() {
          _isEditingName = _nameFocusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = itemDetailProvider(widget.item);
    final currentItem = ref.watch(itemProvider);
    final notifier = ref.read(itemProvider.notifier);

    ref.listen(itemProvider, (previous, next) {
      if (previous != null && previous != next) {
        _hasChanges = true;
        if (previous.name != next.name) {
          _nameController.text = next.name;
          _nameController.selection = TextSelection.fromPosition(
            TextPosition(offset: _nameController.text.length),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(_hasChanges);
          },
        ),
        title: Text(currentItem.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context, notifier, currentItem),
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (!didPop) {
            Navigator.of(context).pop(_hasChanges);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // <<< THAY ĐỔI KHUNG ẢNH TẠI ĐÂY
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  width: double.infinity,
                  color: Colors.white, // Nền trắng
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(
                      File(currentItem.imagePath),
                      fit: BoxFit.contain, // Đổi sang contain
                       errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 60),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: 'Tên món đồ',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isEditingName)
                      FilterChip(
                        label: const Text('Lưu'),
                        selected: true, 
                        onSelected: (isSelected) {
                          notifier.updateName(_nameController.text);
                          _nameFocusNode.unfocus();
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
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
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, ItemDetailNotifier notifier, ClothingItem currentItem) async {
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
  }
}