// lib/widgets/global_add_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/screens/batch_add_item_screen.dart';

class GlobalAddButton extends ConsumerStatefulWidget {
  const GlobalAddButton({super.key});

  @override
  ConsumerState<GlobalAddButton> createState() => _GlobalAddButtonState();
}

class _GlobalAddButtonState extends ConsumerState<GlobalAddButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'global_add_fab',
      onPressed: () {
        // <<< GỌI HÀM HIỂN THỊ BOTTOM SHEET
        _showImageSourceActionSheet(context);
      },
      shape: const CircleBorder(),
      backgroundColor: Colors.black,
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }

  // <<< TÁCH LOGIC RA CÁC HÀM RIÊNG BIỆT CHO RÕ RÀNG
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Chụp ảnh mới'),
              onTap: () {
                Navigator.of(ctx).pop(); // Đóng bottom sheet
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Chọn từ Album'),
              onTap: () {
                Navigator.of(ctx).pop(); // Đóng bottom sheet
                _pickMultiImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final navigator = Navigator.of(context);
    
    final imagePicker = ImagePicker();
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (!mounted || pickedFile == null) return;

    final itemsWereAdded = await navigator.push<bool>(
      MaterialPageRoute(builder: (ctx) => AddItemScreen(newImage: pickedFile)),
    );
    
    if (itemsWereAdded == true) {
      ref.read(itemAddedTriggerProvider.notifier).state++;
    }
  }

  Future<void> _pickMultiImageFromGallery() async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final imagePicker = ImagePicker();
    final List<XFile> pickedFiles = await imagePicker.pickMultiImage(
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (!mounted || pickedFiles.isEmpty) return;

    List<XFile> filesToProcess = pickedFiles;
    if (pickedFiles.length > 10) {
      filesToProcess = pickedFiles.take(10).toList();
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Đã chọn tối đa 10 ảnh. Các ảnh thừa đã được bỏ qua.')),
      );
    }
    
    bool? itemsWereAdded = false;

    if (!mounted) return;

    if (filesToProcess.length == 1) {
      itemsWereAdded = await navigator.push<bool>(
        MaterialPageRoute(builder: (ctx) => AddItemScreen(newImage: filesToProcess.first)),
      );
    } else {
      itemsWereAdded = await navigator.push<bool>(
        MaterialPageRoute(builder: (ctx) => BatchAddItemScreen(images: filesToProcess)),
      );
    }

    if (itemsWereAdded == true) {
      ref.read(itemAddedTriggerProvider.notifier).state++;
    }
  }
}