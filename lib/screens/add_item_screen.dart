// file: lib/screens/add_item_screen.dart

import 'dart:io'; // Cần cho việc sử dụng kiểu File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import thư viện
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:uuid/uuid.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // Key để quản lý trạng thái của Form
  final _formKey = GlobalKey<FormState>();

  // Biến để lưu trữ ảnh người dùng chụp
  File? _selectedImage;
  // Các biến để lưu trữ giá trị nhập vào
  String _enteredName = '';
  String _enteredColor = '';
  String? _selectedCategory; // Dùng ? vì ban đầu nó có thể null

  // Hàm để mở camera và chụp ảnh
  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);

    if (pickedImage == null) {
      return; // Người dùng không chụp ảnh
    }

    setState(() {
      _selectedImage = File(pickedImage.path); // Lưu ảnh đã chụp
    });
  }

  // Hàm xử lý khi nhấn nút Lưu
  void _saveItem() async { // Chuyển hàm thành async
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null || _selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng điền đủ thông tin và chọn ảnh!'))
        );
        return;
      }

      _formKey.currentState!.save();

      // Tạo một đối tượng ClothingItem mới với dữ liệu đã thu thập
      final newItem = ClothingItem(
        id: const Uuid().v4(),
        name: _enteredName,
        category: _selectedCategory!,
        color: _enteredColor,
        imagePath: _selectedImage!.path,
      );
      
      // Lưu vào cơ sở dữ liệu
      await DBHelper.insert('clothing_items', newItem.toMap());

      // Chỉ cần quay về màn hình trước đó, không cần trả dữ liệu
      if (mounted) { // Kiểm tra widget còn tồn tại không trước khi dùng context
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách các danh mục để người dùng chọn
    final categories = ['Áo', 'Quần', 'Váy', 'Giày', 'Phụ kiện'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm đồ mới'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView( // Cho phép cuộn khi bàn phím hiện lên
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vùng hiển thị và chọn ảnh
              GestureDetector(
                onTap: _takePicture,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity)
                      : const Center(child: Icon(Icons.camera_alt, size: 40, color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 16),

              // Ô nhập Tên món đồ
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tên món đồ'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              const SizedBox(height: 16),
              
              // Ô nhập Màu sắc
              TextFormField(
                decoration: const InputDecoration(labelText: 'Màu sắc'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập màu sắc.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredColor = value!;
                },
              ),
              const SizedBox(height: 16),
              
              // Menu thả xuống cho Danh mục
              DropdownButtonFormField(
                value: _selectedCategory,
                items: categories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Danh mục'),
                validator: (value) => value == null ? 'Vui lòng chọn một danh mục.' : null,
              ),
              const SizedBox(height: 32),

              // Nút Lưu
              ElevatedButton.icon(
                onPressed: _saveItem,
                icon: const Icon(Icons.save),
                label: const Text('Lưu'),
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