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

// Bước 1: Dùng `ConsumerStatefulWidget`.
// Lý do: Chúng ta cần `initState` để khởi tạo TextEditingController
// và `dispose` để hủy nó, đồng thời cần `ref` để tương tác với Riverpod.
class AddItemScreen extends ConsumerStatefulWidget {
  final String? preselectedClosetId;
  final ClothingItem? itemToEdit;

  const AddItemScreen({super.key, this.preselectedClosetId, this.itemToEdit});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  // TextEditingController vẫn được quản lý bên trong State của Widget
  late final TextEditingController _nameController;

  // Danh sách tủ đồ chỉ cần load 1 lần, không cần đưa vào StateNotifier
  List<Closet> _closets = [];

  @override
  void initState() {
    super.initState();

    // Khởi tạo controller với giá trị ban đầu (nếu là edit)
    _nameController = TextEditingController(text: widget.itemToEdit?.name ?? '');

    // Load danh sách tủ đồ để hiển thị trong Dropdown
    _loadClosets();

    // Nếu là "Thêm mới" và có closet được chọn sẵn,
    // ta cần cập nhật trạng thái trong Notifier.
    // Dùng Future.microtask để đảm bảo Notifier đã được khởi tạo trước khi gọi.
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
    // Việc load này có thể được đưa vào một provider riêng nếu muốn,
    // nhưng để ở đây cũng không sao vì nó đơn giản.
    final dataList = await DatabaseHelper.instance.getClosets();
    if (mounted) {
      setState(() {
        _closets = dataList.map((item) => Closet.fromMap(item)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bước 2: Lấy state và notifier từ provider
    // Dùng .family() để truyền `widget.itemToEdit` vào, Riverpod sẽ tạo
    // một notifier riêng cho việc thêm mới hoặc cho việc sửa một item cụ thể.
    final provider = addItemProvider(widget.itemToEdit);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    // Bước 3: Dùng ref.listen để xử lý các "sự kiện một lần"
    // như hiển thị SnackBar hoặc điều hướng mà không cần đặt logic trong build.
    ref.listen<AddItemState>(provider, (previous, next) {
      // Nếu có thông báo lỗi mới trong state, hiển thị nó
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: Colors.red,
        ));
      }
      // Nếu trạng thái isSuccess là true, tức là đã lưu thành công
      if (next.isSuccess) {
        // Trả về `true` để các màn hình trước đó biết cần làm mới dữ liệu
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
              onTap: () => notifier.pickImage(ImageSource.camera),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  // UI hiển thị ảnh dựa trên state
                  child: state.image != null
                      ? Image.file(state.image!, fit: BoxFit.cover, width: double.infinity)
                      : (state.imagePath != null
                          ? Image.file(File(state.imagePath!), fit: BoxFit.cover)
                          : const Center(child: Icon(Icons.camera_alt, size: 40, color: Colors.grey))),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tên món đồ
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên món đồ *'),
              // Khi người dùng gõ, gọi hàm trong notifier để cập nhật state
              onChanged: notifier.onNameChanged,
            ),
            const SizedBox(height: 16),

            // Chọn tủ đồ
            if (_closets.isNotEmpty)
              DropdownButtonFormField<String>(
                value: state.selectedClosetId,
                items: _closets.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: notifier.onClosetChanged,
                decoration: const InputDecoration(labelText: 'Chọn tủ đồ *'),
              ),
            const SizedBox(height: 16),
            
            // Chọn danh mục
            const Text('Danh mục *', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 8),
            CategorySelector(
              initialCategory: state.selectedCategoryValue,
              onCategorySelected: notifier.onCategoryChanged,
            ),
            const Divider(height: 32),

            // Các trường đa lựa chọn
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
            // Nút Lưu
            ElevatedButton.icon(
              onPressed: state.isLoading ? null : notifier.saveItem,
              icon: state.isLoading ? const SizedBox.shrink() : const Icon(Icons.save),
              label: state.isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(state.isEditing ? 'Cập nhật' : 'Lưu'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}