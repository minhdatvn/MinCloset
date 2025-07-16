// lib/widgets/closet_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mincloset/helpers/context_extensions.dart';

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
    final l10n = context.l10n; // Lấy l10n một lần ở đầu hàm
    final bool isEditing = widget.initialName != null;

    return AlertDialog(
      iconPadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 3.0),
      icon: Icon(isEditing ? Symbols.edit_square : Symbols.add_column_right, size: 32),
      titlePadding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 0),
      title: Text(isEditing ? l10n.closetDialog_editTitle : l10n.closetDialog_createTitle), // <-- THAY ĐỔI
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            maxLength: 30,
            decoration: InputDecoration(
              labelText: isEditing ? l10n.closetDialog_editLabel : l10n.closetDialog_createLabel, // <-- THAY ĐỔI
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
          child: Text(l10n.common_cancel), // <-- THAY ĐỔI
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.common_save), // <-- THAY ĐỔI
        ),
      ],
    );
  }
}