// lib/screens/pages/outfits_hub_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/outfit_detail_notifier.dart';
import 'package:mincloset/notifiers/outfits_hub_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OutfitsHubPage extends ConsumerStatefulWidget {
  const OutfitsHubPage({super.key});

  @override
  ConsumerState<OutfitsHubPage> createState() => _OutfitsHubPageState();
}

class _OutfitsHubPageState extends ConsumerState<OutfitsHubPage> {
  final ScrollController _scrollController = ScrollController();

  void _showOutfitDetailSheet(
  BuildContext context,
  WidgetRef ref,
  Outfit outfit,
  OutfitsHubNotifier notifier,
) {
  showModalBottomSheet(
    context: context,
    // Bỏ isScrollControlled và DraggableScrollableSheet vì sheet giờ đã nhỏ gọn
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      // Dùng SafeArea và Column để chứa các ListTile
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Giúp Column chỉ chiếm chiều cao cần thiết
          children: <Widget>[
            // Dòng chứa thumbnail, tên và ngày mặc
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  // Ảnh thumbnail tròn
                   SizedBox(
                    width: 60, // Chiều rộng của ảnh
                    height: 80, // Chiều cao (tỷ lệ 3:4)
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8), // Bo tròn góc
                      child: Image.file(
                        File(outfit.thumbnailPath ?? outfit.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback nếu ảnh lỗi
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Cột chứa tên và ngày mặc
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          outfit.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Dòng này vẫn chính xác vì chúng ta đã cập nhật model Outfit
                        Text(
                          'Last worn: ${outfit.lastWornDate != null ? DateFormat.yMMMd().format(outfit.lastWornDate!) : "Never"}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Các ListTile hành động (giữ nguyên như cũ)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showEditOutfitNameDialog(context, ref, outfit, notifier);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.of(ctx).pop(); // Đóng sheet
                // Sử dụng API mới SharePlus.instance.share với ShareParams
                SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(outfit.imagePath)],
                    text: 'Let check out my outfit: "${outfit.name}"!',
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('View full details'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final bool? outfitWasChanged = await Navigator.pushNamed(
                  context,
                  AppRoutes.outfitDetail,
                  arguments: outfit,
                );
                if (outfitWasChanged == true) {
                  notifier.fetchInitialOutfits();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(ctx).pop();
                _showDeleteConfirmationDialog(context, ref, outfit, notifier);
              },
            ),
          ],
        ),
      );
    },
  );
}
  // Hàm để hiện dialog sửa tên (điều chỉnh từ outfit_actions_menu.dart)
  void _showEditOutfitNameDialog(
    BuildContext context,
    WidgetRef ref,
    Outfit outfit,
    OutfitsHubNotifier notifier,
  ) {
    final nameController = TextEditingController(text: outfit.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename outfit'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'New name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              if (nameController.text.trim().isEmpty) return;

              // Gọi đến provider chi tiết để cập nhật
              await ref.read(outfitDetailProvider(outfit).notifier)
                      .updateName(nameController.text.trim());
              
              // Làm mới lại danh sách ở trang Hub
              notifier.fetchInitialOutfits();
              navigator.pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Hàm để hiện dialog xác nhận xóa
  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Outfit outfit,
    OutfitsHubNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm deletion'),
        content: Text('Permanently delete outfit "${outfit.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Gọi hàm xóa từ provider chi tiết
      final success = await ref.read(outfitDetailProvider(outfit).notifier)
                              .deleteOutfit();

      // Nếu xóa thành công, làm mới lại trang Hub
      if (success) {
        notifier.fetchInitialOutfits();
        ref.read(notificationServiceProvider).showBanner(
                message: 'Deleted outfit "${outfit.name}".',
                type: NotificationType.success,
              );
      } else {
        ref.read(notificationServiceProvider).showBanner(
                message: 'Failed to delete outfit. Please try again.',
              );
      }
    }
  }

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
                crossAxisCount: 3,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showOutfitDetailSheet(context, ref, outfit, notifier);
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
                )
                // <<< HIỆU ỨNG >>>
                .animate()
                .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                .slide(
                  begin: const Offset(0, 0.2),
                  duration: 400.ms,
                  curve: Curves.easeOut,
                  delay: (50 * ((index - 1) % 15)).ms, // Chú ý: delay bắt đầu từ index-1 vì item đầu tiên (index=0) là nút thêm
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
      onTap: () {
        // Sử dụng .then() để xử lý kết quả trả về từ trang OutfitBuilder
        // một cách an toàn hơn.
        Navigator.pushNamed(context, AppRoutes.outfitBuilder).then((newOutfitCreated) {
          // Nếu kết quả trả về là true (đã tạo outfit thành công)
          if (newOutfitCreated == true) {
            // Thì làm mới lại danh sách outfits
            ref.read(outfitsHubProvider.notifier).fetchInitialOutfits();
          }
        });
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
                'Create outfits', // <<< SỬA LẠI CHUỖI TEXT Ở ĐÂY >>>
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}