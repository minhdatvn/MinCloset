// lib/screens/pages/closets_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/helpers/dialog_helpers.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/notifiers/closets_page_notifier.dart';
import 'package:mincloset/notifiers/item_detail_notifier.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/pages/outfit_builder_page.dart';
import 'package:mincloset/widgets/item_search_filter_bar.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/widgets/recent_item_card.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:mincloset/widgets/multi_select_action_button.dart';
import 'package:mincloset/widgets/persistent_header_delegate.dart';

IconData _getIconDataFromName(String? iconName) {
  // Đây là map tương tự như ở màn hình EditClosetScreen
  const Map<String, IconData> availableIcons = {
    'Default': Icons.style_outlined,
    'Work': Icons.business_center_outlined,
    'Gym': Icons.fitness_center_outlined,
    'Travel': Icons.flight_takeoff_outlined,
    'Home': Icons.home_outlined,
    'Party': Icons.celebration_outlined,
    'Formal': Icons.theater_comedy_outlined,
  };
  return availableIcons[iconName] ?? Icons.style_outlined; // Trả về icon mặc định nếu không tìm thấy
}

class ClosetsPage extends ConsumerStatefulWidget {
  const ClosetsPage({super.key});
  @override
  ConsumerState<ClosetsPage> createState() => _ClosetsPageState();
}

class _ClosetsPageState extends ConsumerState<ClosetsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Lắng nghe sự thay đổi từ provider và điều khiển TabController
    ref.listenManual(closetsSubTabIndexProvider, (previous, next) {
      // Nếu index của TabController khác với giá trị mới từ provider
      if (_tabController.index != next) {
        // thì thực hiện chuyển tab một cách mượt mà
        _tabController.animateTo(next);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const allItemsProviderId = 'closetsPage';
    final l10n = context.l10n;  

    return PageScaffold(
      appBar: AppBar(
        // Đọc trực tiếp trạng thái isMultiSelectMode từ provider
        automaticallyImplyLeading: !ref.watch(itemFilterProvider(allItemsProviderId)).isMultiSelectMode,
        leading: ref.watch(itemFilterProvider(allItemsProviderId)).isMultiSelectMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => ref.read(itemFilterProvider(allItemsProviderId).notifier).clearSelectionAndExitMode(),
              )
            : null,
        title: Text(
          ref.watch(itemFilterProvider(allItemsProviderId)).isMultiSelectMode
              // Đọc độ dài của danh sách ID đã chọn
              ? l10n.closets_itemsSelected(ref.watch(itemFilterProvider(allItemsProviderId)).selectedItemIds.length)
              : l10n.closets_title,
        ),
        bottom: ref.watch(itemFilterProvider(allItemsProviderId)).isMultiSelectMode
            ? null
            : TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: l10n.closets_tabAllItems),
                  Tab(text: l10n.closets_tabByCloset),
                ],
                onTap: (index) {
                  ref.read(closetsSubTabIndexProvider.notifier).state = index;
                },
              ),
      ),
      body: TabBarView(
        // Khóa việc vuốt chuyển tab khi đang chọn nhiều để tránh lỗi
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: const [
          _AllItemsTab(),
          _ClosetsListTab(),
        ],
      ),
    );
  }
}

// <<< SỬA LẠI HOÀN TOÀN TAB NÀY ĐỂ HỖ TRỢ MULTI-SELECT >>>
class _AllItemsTab extends ConsumerStatefulWidget {
  const _AllItemsTab();
  @override
  ConsumerState<_AllItemsTab> createState() => _AllItemsTabState();
}

class _AllItemsTabState extends ConsumerState<_AllItemsTab> {
  final ScrollController _scrollController = ScrollController();
  static const providerId = 'closetsPage'; // ID cho provider của tab này

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final notifier = ref.read(itemFilterProvider(providerId).notifier);
    final state = ref.read(itemFilterProvider(providerId));
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 &&
        !state.isLoadingMore &&
        !state.isMultiSelectMode && // Không tải thêm khi đang chọn nhiều
        state.hasMore) {
      notifier.fetchMoreItems();
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
    final provider = itemFilterProvider(providerId);
    final notifier = ref.read(provider.notifier);
    final state = ref.watch(provider);
    final l10n = context.l10n;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: notifier.fetchInitialItems,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: PersistentHeaderDelegate(
                child: ItemSearchFilterBar(
                  providerId: providerId,
                  onApplyFilter: notifier.applyFilters,
                  activeFilters: ref.watch(itemFilterProvider(providerId)).activeFilters,
                ),
              ),
            ),
            // Xử lý các trạng thái loading/empty/error
            if (state.isLoading && state.items.isEmpty)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (state.errorMessage != null && state.items.isEmpty)
              SliverFillRemaining(child: Center(child: Text(state.errorMessage!)))
            else if (state.items.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      state.searchQuery.isNotEmpty || state.activeFilters.isApplied 
                        ? l10n.allItems_noItemsFound 
                        : l10n.allItems_emptyCloset,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                )
            else
              _buildItemsGrid(state.items, state.hasMore, state.isMultiSelectMode),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      child: state.isMultiSelectMode
          ? BottomAppBar(
              key: const ValueKey('closets_page_bottom_bar'),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Các nút bấm giữ nguyên như cũ
                  MultiSelectActionButton(
                    icon: Icons.delete_outline,
                    label: l10n.allItems_delete,
                    color: Colors.red,
                    onPressed: () async {
                      final confirmed = await showAnimatedDialog<bool>(
                        context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.allItems_deleteDialogTitle),
                          content: Text(l10n.allItems_deleteDialogContent(state.selectedItemIds.length)), 
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.common_cancel)), 
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: Text(l10n.allItems_delete), 
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await notifier.deleteSelectedItems();
                      }
                    },
                  ),
                  MultiSelectActionButton(
                    icon: Icons.add_to_photos_outlined,
                    label: l10n.allItems_createOutfit,
                    onPressed: () {
                      final selectedItems = state.items.where((item) => state.selectedItemIds.contains(item.id)).toList();
                      notifier.clearSelectionAndExitMode();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => OutfitBuilderPage(preselectedItems: selectedItems)));
                    },
                  ),
                ],
              ),
            )
          // Khi không ở chế độ chọn nhiều, widget sẽ là một hộp rỗng
          : const SizedBox.shrink(key: ValueKey('empty_closets_page_bar')),
      ),
    );
  }

  Widget _buildItemsGrid(List<ClothingItem> items, bool hasMore, bool isMultiSelectMode) {
    final provider = itemFilterProvider(providerId);
    final notifier = ref.read(provider.notifier);
    final state = ref.watch(provider);
    
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid.builder(
        itemCount: items.length + (hasMore && !isMultiSelectMode ? 1 : 0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (ctx, index) {
          if (index >= items.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final item = items[index];
          final isSelected = state.selectedItemIds.contains(item.id);

          return GestureDetector(
            onLongPress: () {
              if (!isMultiSelectMode) {
                notifier.enableMultiSelectMode(item.id);
              }
            },
            onTap: () async {
              if (isMultiSelectMode) {
                notifier.toggleItemSelection(item.id);
              } else {
                final wasChanged = await Navigator.pushNamed(context, AppRoutes.addItem, arguments: ItemDetailNotifierArgs(tempId: item.id, itemToEdit: item));
                if (wasChanged == true) {
                  ref.read(itemChangedTriggerProvider.notifier).state++;
                }
              }
            },
            child: RecentItemCard(item: item, isSelected: isSelected),
          )
          // <<< HIỆU ỨNG >>>
          .animate()
          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
          .slide(
            begin: const Offset(0, 0.2), // Sửa .slideUp() thành .slide()
            duration: 400.ms,
            curve: Curves.easeOut,
            delay: (50 * (index % 15)).ms, // Thêm delay tăng dần cho hiệu ứng stagger
          );
        },
      ),
    );
  }
}

// _ClosetsListTab không thay đổi
class _ClosetsListTab extends ConsumerStatefulWidget {
  const _ClosetsListTab();

  @override
  ConsumerState<_ClosetsListTab> createState() => _ClosetsListTabState();
}

class _ClosetsListTabState extends ConsumerState<_ClosetsListTab> {
  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi từ Notifier để hiển thị banner
    ref.listen<ClosetsPageState>(closetsPageProvider, (previous, next) {
      final notificationService = ref.read(notificationServiceProvider);
      final notifier = ref.read(closetsPageProvider.notifier);

      if (next.successMessage != null) {
        notificationService.showBanner(
          message: next.successMessage!,
          type: NotificationType.success,
        );
        notifier.clearMessages(); // Xóa thông báo sau khi đã hiển thị
      }
      if (next.errorMessage != null) {
        notificationService.showBanner(message: next.errorMessage!);
        notifier.clearMessages(); // Xóa thông báo sau khi đã hiển thị
      }
    });

    final closetsAsyncValue = ref.watch(closetsProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return closetsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (closets) {
        final isLimitReached = closets.length >= 10;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: closets.length + 1,
          itemBuilder: (ctx, index) {
            if (index == 0) {
              if (isLimitReached) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Text(
                      l10n.byCloset_limitReached,
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 90, // 1. Đặt chiều cao cố định là 90
                child: Showcase(
                  key: QuestHintKeys.createClosetHintKey,
                  title: l10n.byCloset_addClosetHintTitle,
                  description: l10n.byCloset_addClosetHintDescription,
                  child: Card(
                    margin: EdgeInsets.zero, // 2. Đặt margin và elevation để khớp với thẻ closet
                    elevation: 0,
                    color: theme.colorScheme.primary.withValues(alpha:0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.primary, width: 1.5) // Thêm viền để nổi bật
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell( // 3. Bọc bằng InkWell để có hiệu ứng ripple
                      onTap: () {
                            // Chỉ cần điều hướng đến màn hình mới, không cần truyền gì cả
                            Navigator.pushNamed(context, AppRoutes.editCloset);
                          },
                      child: Center(
                        child: ListTile(
                          leading: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                          title: Text(l10n.byCloset_addNewCloset, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            final closet = closets[index - 1];
            final Color cardColor;
            if (closet.colorHex != null && closet.colorHex!.isNotEmpty) {
              final colorString = closet.colorHex!.replaceAll("#", "");
              final colorValue = int.tryParse(colorString, radix: 16);
              cardColor = colorValue != null ? Color(0xFF000000 | colorValue) : theme.colorScheme.surfaceContainerHighest;
            } else {
              cardColor = theme.colorScheme.surfaceContainerHighest;
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Dismissible(
                  key: ValueKey(closet.id),
                  background: Container(
                    color: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    alignment: Alignment.centerLeft,
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      final confirmed = await showAnimatedDialog<bool>(
                        context,
                        builder: (dialogCtx) => AlertDialog(
                          title: Text(l10n.byCloset_deleteDialogTitle),
                          content: Text(l10n.byCloset_deleteDialogContent(closet.name)),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(dialogCtx).pop(false), child: Text(l10n.common_cancel)),
                            TextButton(
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              onPressed: () => Navigator.of(dialogCtx).pop(true),
                              child: Text(l10n.allItems_delete),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                          // Chỉ cần gọi notifier để xóa
                          await ref.read(closetsPageProvider.notifier).deleteCloset(closet.id, l10n: l10n);
                      }
                      // Luôn trả về false để Dismissible không tự xóa widget
                      // Việc cập nhật UI sẽ do provider đảm nhiệm
                      return false; 
                    } else {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.editCloset,
                        arguments: closet, // Truyền đối tượng closet cần sửa
                      );
                      // Không cần làm gì sau khi pop vì Notifier đã tự động cập nhật
                      return false; // Luôn trả về false
                    }
                  },
                  child: SizedBox(
                    height: 90,
                    child: Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      color: cardColor,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      clipBehavior: Clip.antiAlias,
                      child: Center(
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.closetDetail, arguments: closet),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                            // 2. SỬ DỤNG ICON ĐÃ LẤY TỪ HÀM HELPER
                            leading: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  // Làm màu nền của icon hơi tối hơn màu thẻ một chút
                                  color: Color.alphaBlend(Colors.black.withValues(alpha:0.05), cardColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getIconDataFromName(closet.iconName), // <-- SỬ DỤNG HÀM MỚI
                                  color: theme.colorScheme.onSurface,
                                  size: 32
                                ),
                              ),
                            ),
                            title: Text(closet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Consumer(
                              builder: (context, ref, child) {
                                final itemsCountAsync = ref.watch(itemsInClosetProvider(closet.id));
                                return itemsCountAsync.when(
                                  data: (items) => Text(l10n.byCloset_itemCount(items.length)),
                                  loading: () => Text(l10n.byCloset_itemCountLoading),
                                  error: (err, stack) => Text(l10n.byCloset_itemCountError),
                                );
                              },
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        ),
                    ),
                  ),
                ),
              ),
              )
            );
          },
        );
      },
    );
  }
}