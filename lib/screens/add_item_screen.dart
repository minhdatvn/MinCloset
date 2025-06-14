import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/widgets/category_selector.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';
import 'package:uuid/uuid.dart';

class AddItemScreen extends StatefulWidget {
  final String? preselectedClosetId;
  final ClothingItem? itemToEdit;

  const AddItemScreen({super.key, this.preselectedClosetId, this.itemToEdit});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  File? _selectedImage;
  String _selectedCategoryValue = '';
  List<Closet> _closets = [];
  String? _selectedClosetId;
  bool get _isEditing => widget.itemToEdit != null;

  final Set<String> _selectedSeasons = {};
  final Set<String> _selectedOccasions = {};
  final Set<String> _selectedMaterials = {};
  final Set<String> _selectedPatterns = {};
  final Set<String> _selectedColors = {};

  Set<String> _stringToSet(String? s) {
    if (s == null || s.isEmpty) return {};
    return s.split(', ').toSet();
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final item = widget.itemToEdit!;
      _nameController.text = item.name;
      _selectedCategoryValue = item.category;
      _selectedClosetId = item.closetId;
      if (item.imagePath.isNotEmpty) _selectedImage = File(item.imagePath);

      _selectedSeasons.addAll(_stringToSet(item.season));
      _selectedOccasions.addAll(_stringToSet(item.occasion));
      _selectedMaterials.addAll(_stringToSet(item.material));
      _selectedPatterns.addAll(_stringToSet(item.pattern));
      _selectedColors.addAll(_stringToSet(item.color));
    } else {
      _selectedClosetId = widget.preselectedClosetId;
    }
    _loadClosets();
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

  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);
    if (pickedImage == null) return;
    setState(() { _selectedImage = File(pickedImage.path); });
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null || _selectedCategoryValue.isEmpty || _selectedClosetId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ thông tin bắt buộc!')));
        return;
      }
      _formKey.currentState!.save();
      
      final clothingData = {
        'name': _nameController.text,
        'category': _selectedCategoryValue,
        'closetId': _selectedClosetId!,
        'imagePath': _selectedImage!.path,
        'color': _selectedColors.join(', '),
        'season': _selectedSeasons.join(', '),
        'occasion': _selectedOccasions.join(', '),
        'material': _selectedMaterials.join(', '),
        'pattern': _selectedPatterns.join(', '),
      };

      if (_isEditing) {
        clothingData['id'] = widget.itemToEdit!.id;
        final updatedItem = ClothingItem.fromMap(clothingData);
        await DatabaseHelper.instance.updateItem(updatedItem);
      } else {
        clothingData['id'] = const Uuid().v4();
        final newItem = ClothingItem.fromMap(clothingData);
        await DatabaseHelper.instance.insertItem(newItem.toMap());
      }
      
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Sửa món đồ' : 'Thêm đồ mới')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio( // <-- BỌC BÊN NGOÀI
                aspectRatio: 1 / 1, // Tỷ lệ chiều rộng / chiều cao = 1:1 (hình vuông)
                child: GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity)
                        : const Center(child: Icon(Icons.camera_alt, size: 40, color: Colors.grey)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên món đồ *'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập tên.' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedClosetId,
                items: _closets.map((closet) => DropdownMenuItem(value: closet.id, child: Text(closet.name))).toList(),
                onChanged: (value) => setState(() => _selectedClosetId = value),
                decoration: const InputDecoration(labelText: 'Chọn tủ đồ *'),
                validator: (value) => value == null ? 'Vui lòng chọn một tủ đồ.' : null,
              ),
              const SizedBox(height: 16),
              const Text('Danh mục *', style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 8),
              CategorySelector(
                initialCategory: _selectedCategoryValue,
                onCategorySelected: (newCategory) {
                  setState(() {
                    _selectedCategoryValue = newCategory;
                  });
                },
              ),
              const Divider(height: 32),
              MultiSelectChipField(
                label: 'Màu sắc', allOptions: AppOptions.colors, initialSelections: _selectedColors,
                onSelectionChanged: (newSelections) => setState(() { _selectedColors..clear()..addAll(newSelections); }),
              ),
              const SizedBox(height: 16),
              MultiSelectChipField(
                label: 'Mùa', allOptions: AppOptions.seasons, initialSelections: _selectedSeasons,
                onSelectionChanged: (newSelections) => setState(() { _selectedSeasons..clear()..addAll(newSelections); }),
              ),
              const SizedBox(height: 16),
              MultiSelectChipField(
                label: 'Mục đích', allOptions: AppOptions.occasions, initialSelections: _selectedOccasions,
                onSelectionChanged: (newSelections) => setState(() { _selectedOccasions..clear()..addAll(newSelections); }),
              ),
              const SizedBox(height: 16),
              MultiSelectChipField(
                label: 'Chất liệu', allOptions: AppOptions.materials, initialSelections: _selectedMaterials,
                onSelectionChanged: (newSelections) => setState(() { _selectedMaterials..clear()..addAll(newSelections); }),
              ),
              const SizedBox(height: 16),
              MultiSelectChipField(
                label: 'Họa tiết', allOptions: AppOptions.patterns, initialSelections: _selectedPatterns,
                onSelectionChanged: (newSelections) => setState(() { _selectedPatterns..clear()..addAll(newSelections); }),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saveItem, icon: const Icon(Icons.save),
                label: Text(_isEditing ? 'Cập nhật' : 'Lưu'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}