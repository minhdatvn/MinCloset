// lib/widgets/global_add_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/routing/app_routes.dart';

class GlobalAddButton extends ConsumerStatefulWidget {
  const GlobalAddButton({super.key});

  @override
  ConsumerState<GlobalAddButton> createState() => _GlobalAddButtonState();
}

class _GlobalAddButtonState extends ConsumerState<GlobalAddButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      heroTag: 'global_add_fab',
      onPressed: () {
        _showImageSourceActionSheet(context);
      },
      shape: const CircleBorder(),
      backgroundColor: theme.colorScheme.primary,
      child: Icon(Icons.add, color: theme.colorScheme.onPrimary, size: 30),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAndAnalyzeImages(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from album (up to 10)'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAndAnalyzeImages(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndAnalyzeImages(ImageSource source) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final imagePicker = ImagePicker();

    List<XFile> pickedFiles = [];

    if (source == ImageSource.gallery) {
      pickedFiles = await imagePicker.pickMultiImage(
        maxWidth: 1024,
        imageQuality: 85,
      );
    } else {
      final singleFile = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (singleFile != null) {
        pickedFiles.add(singleFile);
      }
    }

    if (!mounted || pickedFiles.isEmpty) return;

    List<XFile> filesToProcess = pickedFiles;
    if (pickedFiles.length > 10) {
      filesToProcess = pickedFiles.take(10).toList();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
            content: Text('Maximum of 10 photos selected. Extra photos were skipped.')),
      );
    }

    final itemsWereAdded = await navigator.pushNamed(
      AppRoutes.analysisLoading,
      arguments: filesToProcess,
    );

    if (itemsWereAdded == true) {
      ref.read(itemChangedTriggerProvider.notifier).state++;
    }
  }
}