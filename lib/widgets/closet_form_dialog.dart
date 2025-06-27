// lib/widgets/closet_form_dialog.dart
import 'package:flutter/material.dart';

class ClosetFormDialog extends StatefulWidget {
  // Tham số để truyền vào tên closet ban đầu (dùng cho chế độ Edit)
  final String? initialName;
  // Một hàm callback để xử lý logic khi người dùng nhấn Save
  final Future<String?> Function(String name) onSubmit;

  const ClosetFormDialog({
    super.key,
    this.initialName,
    required this.onSubmit,
  });

  @override
  State<ClosetFormDialog> createState() => _ClosetFormDialogState();
}

class _ClosetFormDialogState extends State<ClosetFormDialog> {
  late final TextEditingController _nameController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với giá trị ban đầu nếu có
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Gọi hàm logic được truyền từ bên ngoài
    final error = await widget.onSubmit(_nameController.text);
    
    // Nếu widget vẫn còn tồn tại
    if (mounted) {
      if (error == null) {
        // Thành công, đóng dialog
        Navigator.of(context).pop();
      } else {
        // Thất bại, cập nhật state để hiển thị lỗi
        setState(() {
          _errorText = error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Xác định xem đây là dialog Add hay Edit
    final bool isEditing = widget.initialName != null;

    return AlertDialog(
      icon: Icon(isEditing ? Icons.edit_note_outlined : Icons.create_new_folder_outlined, size: 32),
      title: Text(isEditing ? 'Edit closet name' : 'Create new closet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            maxLength: 30,
            decoration: InputDecoration(
              labelText: isEditing ? 'New name' : 'Closet name',
              errorText: _errorText,
              errorMaxLines: 2,
            ),
            onChanged: (_) {
              if (_errorText != null) {
                setState(() {
                  _errorText = null;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}