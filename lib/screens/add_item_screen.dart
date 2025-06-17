// lib/screens/add_item_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mincloset/widgets/category_selector.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  final String? preselectedClosetId;
  final ClothingItem? itemToEdit;

  const AddItemScreen({super.key, this.preselectedClosetId, this.itemToEdit});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  late final TextEditingController _nameController;
  List<Closet> _closets = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.itemToEdit?.name ?? '');
    _loadClosets();

    if (widget.itemToEdit == null && widget.preselectedClosetId != null) {
      Future.microtask(() => ref
          .read(addItemProvider(widget.itemToEdit).notifier)
          .onClosetChanged(widget.preselectedClosetId));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadClosets() async {
    final closetsData = await ref.read(closetRepositoryProvider).getClosets();
    if (mounted) {
      setState(() {
        _closets = closetsData;
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    final notifier = ref.read(addItemProvider(widget.itemToEdit).notifier);
    
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ Album'),
              onTap: () {
                notifier.pickImage(ImageSource.gallery);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Chụp ảnh'),
              onTap: () {
                notifier.pickImage(ImageSource.camera);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = addItemProvider(widget.itemToEdit);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    
    ref.listen<AddItemState>(provider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
      if (next.isSuccess) {
        Navigator.of(context).pop(true);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(state.isEditing ? 'Sửa món đồ' : 'Thêm đồ mới')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _showImageSourceActionSheet(context),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: state.image != null
                          ? Image.file(state.image!, fit: BoxFit.contain)
                          : (state.imagePath != null
                              ? Image.file(File(state.imagePath!), fit: BoxFit.contain)
                              : const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text('Thêm ảnh', style: TextStyle(color: Colors.grey))
                                    ],
                                  ),
                                )),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên món đồ *',
                border: OutlineInputBorder(),
              ),
              onChanged: notifier.onNameChanged,
            ),
            const SizedBox(height: 16),

            // <<< SỬA LỖI CÚ PHÁP TẠI ĐÂY
            // Sử dụng "collection if" để thêm có điều kiện nhiều widget
            if (_closets.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: state.selectedClosetId,
                items: _closets.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: notifier.onClosetChanged,
                decoration: const InputDecoration(
                  labelText: 'Chọn tủ đồ *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            CategorySelector(
              initialCategory: state.selectedCategoryValue,
              onCategorySelected: notifier.onCategoryChanged,
            ),
            const Divider(height: 32),
            
            MultiSelectChipField(
              label: 'Màu sắc',
              allOptions: AppOptions.colors,
              initialSelections: state.selectedColors,
              onSelectionChanged: notifier.onColorsChanged,
            ),
            MultiSelectChipField(
              label: 'Mùa',
              allOptions: AppOptions.seasons,
              initialSelections: state.selectedSeasons,
              onSelectionChanged: notifier.onSeasonsChanged,
            ),
             MultiSelectChipField(
              label: 'Mục đích',
              allOptions: AppOptions.occasions,
              initialSelections: state.selectedOccasions,
              onSelectionChanged: notifier.onOccasionsChanged,
            ),
             MultiSelectChipField(
              label: 'Chất liệu',
              allOptions: AppOptions.materials,
              initialSelections: state.selectedMaterials,
              onSelectionChanged: notifier.onMaterialsChanged,
            ),
             MultiSelectChipField(
              label: 'Họa tiết',
              allOptions: AppOptions.patterns,
              initialSelections: state.selectedPatterns,
              onSelectionChanged: notifier.onPatternsChanged,
            ),
            
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: state.isLoading ? null : notifier.saveItem,
              icon: state.isLoading ? const SizedBox.shrink() : const Icon(Icons.save),
              label: state.isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(state.isEditing ? 'Cập nhật' : 'Lưu'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}