// lib/screens/log_wear_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/log_wear_notifier.dart';
import 'package:mincloset/states/log_wear_state.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/widgets/recent_item_card.dart';

class LogWearScreen extends ConsumerStatefulWidget {
  final LogWearNotifierArgs args;
  const LogWearScreen({super.key, required this.args});

  @override
  ConsumerState<LogWearScreen> createState() => _LogWearScreenState();
}

class _LogWearScreenState extends ConsumerState<LogWearScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final notifier = ref.read(logWearProvider(widget.args).notifier);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      notifier.fetchMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = logWearProvider(widget.args);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    
    final String title = widget.args.type == SelectionType.items ? 'Select Items' : 'Select Outfits';

    return PageScaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: state.selectedIds.isEmpty
                  ? null
                  : () {
                      // Trả về danh sách các ID đã chọn
                      Navigator.of(context).pop(state.selectedIds);
                    },
              child: const Text('Save'),
            ),
          )
        ],
      ),
      body: _buildGrid(state, notifier),
    );
  }

  Widget _buildGrid(LogWearState state, LogWearNotifier notifier) {
    if (state.isLoading && state.allData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null) {
      return Center(child: Text('Error: ${state.errorMessage}'));
    }
    if (state.allData.isEmpty) {
      return Center(child: Text('No ${widget.args.type.name} to select.'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.allData.length + (state.isLoadingMore ? 1 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (ctx, index) {
        if (index >= state.allData.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final dynamic data = state.allData[index];
        late final String id;
        late final ClothingItem itemForCard;

        if (data is ClothingItem) {
          id = data.id;
          itemForCard = data;
        } else if (data is Outfit) {
          id = data.id;
          itemForCard = ClothingItem(
            id: data.id,
            name: data.name,
            category: 'Outfit',
            closetId: '',
            imagePath: data.imagePath,
            thumbnailPath: data.thumbnailPath,
            color: '',
          );
        } else {
          return const SizedBox.shrink();
        }

        final isSelected = state.selectedIds.contains(id);

        return GestureDetector(
          onTap: () => notifier.toggleSelection(id),
          child: RecentItemCard(
            item: itemForCard,
            isSelected: isSelected,
          ),
        );
      },
    );
  }
}