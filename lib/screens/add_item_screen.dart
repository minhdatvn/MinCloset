import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:uuid/uuid.dart';

class AddItemScreen extends StatefulWidget {
  final String? preselectedClosetId;
  final ClothingItem? itemToEdit; // Thuộc tính để nhận món đồ cần sửa

  const AddItemScreen({super.key, this.preselectedClosetId, this.itemToEdit});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _colorController = TextEditingController();

  File? _selectedImage;
  String? _selectedCategory;
  List<Closet> _closets = [];
  String? _selectedClosetId;
  bool get _isEditing => widget.itemToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final item = widget.itemToEdit!;
      _nameController.text = item.name;
      _colorController.text = item.color;
      _selectedCategory = item.category;
      _selectedClosetId = item.closetId;
      if (item.imagePath.isNotEmpty) {
        _selectedImage = File(item.imagePath);
      }
    } else {
      _selectedClosetId = widget.preselectedClosetId;
    }
    _loadClosets();
  }

  Future<void> _loadClosets() async {
    final dataList = await DBHelper.getClosets('closets');
    if (mounted) {
      setState(() {
        _closets = dataList.map((item) => Closet.fromMap(item)).toList();
      });
    }
  }

  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);
    if (pickedImage == null) return;
    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null || _selectedCategory == null || _selectedClosetId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ tất cả thông tin!')));
        return;
      }
      
      _formKey.currentState!.save();
      
      if (_isEditing) {
        final updatedItem = ClothingItem(
          id: widget.itemToEdit!.id,
          name: _nameController.text,
          category: _selectedCategory!,
          color: _colorController.text,
          imagePath: _selectedImage!.path,
          closetId: _selectedClosetId!,
        );
        await DBHelper.updateItem(updatedItem);
      } else {
        final newItem = ClothingItem(
          id: const Uuid().v4(),
          name: _nameController.text,
          category: _selectedCategory!,
          color: _colorController.text,
          imagePath: _selectedImage!.path,
          closetId: _selectedClosetId!,
        );
        await DBHelper.insert('clothing_items', newItem.toMap());
      }
      
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Áo', 'Quần', 'Váy', 'Giày', 'Phụ kiện'];
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa món đồ' : 'Thêm đồ mới'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _takePicture,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  child: _selectedImage != null ? Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity) : const Center(child: Icon(Icons.camera_alt, size: 40, color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên món đồ'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập tên.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Màu sắc'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập màu sắc.' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedClosetId,
                items: _closets.map((closet) => DropdownMenuItem(value: closet.id, child: Text(closet.name))).toList(),
                onChanged: (value) => setState(() => _selectedClosetId = value),
                decoration: const InputDecoration(labelText: 'Chọn tủ đồ'),
                validator: (value) => value == null ? 'Vui lòng chọn một tủ đồ.' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                decoration: const InputDecoration(labelText: 'Danh mục'),
                validator: (value) => value == null ? 'Vui lòng chọn một danh mục.' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saveItem,
                icon: const Icon(Icons.save),
                label: Text(_isEditing ? 'Cập nhật' : 'Lưu'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}