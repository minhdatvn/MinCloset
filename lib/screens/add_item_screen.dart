// lib/screens/add_item_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
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
    final dataList = await DatabaseHelper.instance.getClosets();
    if (mounted) {
      setState(() {
        _closets = dataList.map((item) => Closet.fromMap(item)).toList();
      });
    }
  }

  // <<< THÊM HÀM MỚI NÀY ĐỂ HIỂN THỊ LỰA CHỌN
  void _showImageSourceActionSheet(BuildContext context) {
    // Lấy ra notifier để có thể gọi hàm từ bên trong bottom sheet
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
                // Gọi hàm pickImage với nguồn là gallery
                notifier.pickImage(ImageSource.gallery);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Chụp ảnh'),
              onTap: () {
                // Gọi hàm pickImage với nguồn là camera
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
            // Image Picker
            GestureDetector(
              // <<< THAY ĐỔI Ở ĐÂY: onTap giờ sẽ gọi hàm hiển thị lựa chọn
              onTap: () => _showImageSourceActionSheet(context),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  child: state.image != null
                      ? Image.file(state.image!, fit: BoxFit.cover)
                      : (state.imagePath != null
                          ? Image.file(File(state.imagePath!), fit: BoxFit.cover)
                          : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Thêm ảnh', style: TextStyle(color: Colors.grey))
                              ],
                            ),
                          )
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // ... phần còn lại của Form giữ nguyên ...
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên món đồ *'),
              onChanged: notifier.onNameChanged,
            ),
            const SizedBox(height: 16),

            if (_closets.isNotEmpty)
              DropdownButtonFormField<String>(
                value: state.selectedClosetId,
                items: _closets.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: notifier.onClosetChanged,
                decoration: const InputDecoration(labelText: 'Chọn tủ đồ *'),
              ),
            const SizedBox(height: 16),
            
            const Text('Danh mục *', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 8),
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