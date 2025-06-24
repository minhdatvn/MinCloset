// lib/screens/pages/outfits_hub_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/outfits_hub_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/widgets/outfit_actions_menu.dart';

class OutfitsHubPage extends ConsumerStatefulWidget {
  const OutfitsHubPage({super.key});

  @override
  ConsumerState<OutfitsHubPage> createState() => _OutfitsHubPageState();
}

class _OutfitsHubPageState extends ConsumerState<OutfitsHubPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !ref.read(outfitsHubProvider).isLoadingMore &&
        ref.read(outfitsHubProvider).hasMore) {
      ref.read(outfitsHubProvider.notifier).fetchMoreOutfits();
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
    final state = ref.watch(outfitsHubProvider);
    final notifier = ref.read(outfitsHubProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Outfits'),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.fetchInitialOutfits,
        child: Builder(
          builder: (context) {
            if (state.isLoading && state.outfits.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null && state.outfits.isEmpty) {
              return Center(child: Text(state.error!));
            }

            // <<< SỬA ĐỔI LOGIC HIỂN THỊ TẠI ĐÂY >>>
            // GridView sẽ luôn được build, kể cả khi list rỗng
            return GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              // itemCount = (số outfit) + 1 (cho nút thêm) + 1 (nếu đang tải thêm)
              itemCount: state.outfits.length + 1 + (state.isLoadingMore ? 1 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (ctx, index) {
                // Ô đầu tiên luôn là nút "Thêm mới"
                if (index == 0) {
                  return _buildAddOutfitCard(context, ref);
                }

                // Nếu index nằm ngoài phạm vi của list, đó là ô loading
                if (index > state.outfits.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Hiển thị thẻ outfit bình thường
                // index-1 vì ô đầu tiên là nút thêm
                final outfit = state.outfits[index - 1];
                final imageToShowPath = outfit.thumbnailPath ?? outfit.imagePath;

                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final bool? outfitWasChanged = await Navigator.pushNamed(context, AppRoutes.outfitDetail, arguments: outfit);
                                if (outfitWasChanged == true) {
                                  notifier.fetchInitialOutfits();
                                }
                              },
                              child: Image.file(
                                File(imageToShowPath),
                                key: ValueKey(imageToShowPath),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40));
                                },
                              ),
                            ),
                            if (outfit.isFixed)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(153),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.lock_outline, color: Colors.white, size: 16),
                                ),
                              )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Expanded(child: Text(outfit.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                            OutfitActionsMenu(
                              outfit: outfit,
                              onUpdate: () {
                                notifier.fetchInitialOutfits();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddOutfitCard(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        final bool? newOutfitCreated = await Navigator.pushNamed(context, AppRoutes.outfitBuilder);
        if (newOutfitCreated == true) {
          ref.read(outfitsHubProvider.notifier).fetchInitialOutfits();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 40, color: Colors.grey.shade600),
              const SizedBox(height: 8),
              const Text(
                'Create a New Outfit',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}