// lib/widgets/global_add_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/screens/add_item_screen.dart';

class GlobalAddButton extends ConsumerWidget {
  const GlobalAddButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      heroTag: 'global_add_fab',
      onPressed: () async {
        // Điều hướng đến trang Thêm đồ mới và chờ kết quả
        final bool? itemWasAdded = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (ctx) => const AddItemScreen()),
        );

        // Nếu kết quả trả về là true (đã thêm thành công)
        if (itemWasAdded == true) {
          // Phát tín hiệu bằng cách cập nhật trigger provider
          ref.read(itemAddedTriggerProvider.notifier).state++;
        }
      },
      shape: const CircleBorder(),
      backgroundColor: Colors.black,
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }
}