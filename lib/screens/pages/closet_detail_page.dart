// lib/screens/pages/closet_detail_page.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/widgets/recent_item_card.dart';

class ClosetDetailPage extends ConsumerWidget {
  final Closet closet;
  const ClosetDetailPage({super.key, required this.closet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsyncValue = ref.watch(itemsInClosetProvider(closet.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(closet.name),
      ),
      body: itemsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Your closet is empty.\nPlease add items!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return _buildItemsGrid(context, ref, items);
        },
      ),
    );
  }

  Widget _buildItemsGrid(BuildContext context, WidgetRef ref, List<ClothingItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (ctx, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () async {
            final itemWasChanged = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (context) => AddItemScreen(itemToEdit: item)),
            );
            if (itemWasChanged == true && context.mounted) {
              final closetId = item.closetId;
              // <<< ĐÃ XÓA BỎ CÂU LỆNH IF THỪA THÃI Ở ĐÂY
              ref.invalidate(itemsInClosetProvider(closetId));
            }
          },
          child: RecentItemCard(item: item),
        );
      },
    );
  }
}