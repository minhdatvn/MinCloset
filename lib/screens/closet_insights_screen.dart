// lib/screens/closet_insights_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/models/closet_insights.dart';
import 'package:mincloset/domain/models/item_insight.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/notifiers/calendar_notifier.dart';
import 'package:mincloset/notifiers/closet_insights_notifier.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/states/log_wear_state.dart';

// --- MÀN HÌNH CHÍNH ---
class ClosetInsightsScreen extends ConsumerWidget {
  const ClosetInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(closetInsightsProvider);
    final notifier = ref.read(closetInsightsProvider.notifier);
    final userName = ref.watch(profileProvider.select((s) => s.userName)) ?? 'You';

    return Scaffold(
      // Bỏ AppBar ở đây vì chúng ta sẽ dùng SliverAppBar
      body: RefreshIndicator(
        onRefresh: notifier.fetchInsights,
        child: _buildBody(context, state, userName),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ClosetInsightsState state, String userName) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(state.errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }
    if (state.insights == null) {
      return const Center(child: Text('No insights available.'));
    }

    // Sử dụng CustomScrollView để kết hợp các loại list khác nhau
    return CustomScrollView(
      slivers: [
        // 1. "Ảnh bìa" - Khu vực mở đầu
        _buildMagazineCover(context, userName, state.insights!),

        // 2. "Editor's Picks" - Những ngôi sao của tủ đồ
        _buildSectionHeader(context, "The Most-Loved Pieces"),
        _buildMostWornList(state.insights!.mostWornItems),
        
        // 3. "Feature Article" - Phân tích đầu tư thông minh
        _buildSectionHeader(context, "Smartest Investments"),
        _buildBestValueGrid(state.insights!.bestValueItems),

        // 4. "Hidden Gems" - Khám phá lại kho báu bị lãng quên
        _buildSectionHeader(context, "Rediscover Your Closet"),
        _buildForgottenItemsStack(context, state.insights!.forgottenItems),
        
        // 5. "The Numbers" - Infographic cuối trang
        _buildSectionHeader(
            context, 
            "Investment Focus",
            totalValue: state.insights!.totalValue, // <-- TRUYỀN TỔNG GIÁ TRỊ VÀO
        ),
        _buildCategoryAnalysis(context, state.insights!),
        
        // Thêm một khoảng trống ở cuối để cuộn đẹp hơn
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }

  // --- CÁC WIDGET HELPER CHO TỪNG PHẦN ---

  // 1. Widget cho "Ảnh bìa" (SliverAppBar)
  Widget _buildMagazineCover(BuildContext context, String userName, ClosetInsights insights) {
    final theme = Theme.of(context);
    
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Builder(
        builder: (context) {
          final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
          // Chỉ hiển thị title khi AppBar đã thu nhỏ gần như hoàn toàn
          final showTitle = (settings?.currentExtent ?? 0) <= (settings?.minExtent ?? 0) + 1;

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            // Điều khiển độ mờ dựa trên biến showTitle
            opacity: showTitle ? 1.0 : 0.0,
            child: const Text('Closet Insights'),
          );
        },
      ),
      titleSpacing: 0,

      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/insights/ins_bg.webp', // <-- SỬ DỤNG ẢNH NỀN CỦA BẠN
              fit: BoxFit.cover,
            ),
            // Lớp 2: Lớp phủ Gradient (THAY THẾ HIỆU ỨNG MỜ)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center, // Dừng ở giữa để phần trên của ảnh rõ nét
                  colors: [
                    // Bắt đầu bằng màu nền của ứng dụng
                    theme.scaffoldBackgroundColor, 
                    // Chuyển dần sang trong suốt
                    theme.scaffoldBackgroundColor.withValues(alpha:0.0), 
                  ],
                  // Điều chỉnh điểm dừng để gradient mượt hơn
                  stops: const [0.0, 0.8], 
                ),
              ),
            ),
            // Tiêu đề lớn (vẫn giữ nguyên ở đây để hiển thị khi mở rộng)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MINCLOSET EXCLUSIVE",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Inside $userName's Style Journey",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // --- KẾT THÚC SỬA LỖI ---
    );
  }

  // Widget chung cho các tiêu đề mục
  Widget _buildSectionHeader(BuildContext context, String title, {double? totalValue}) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      // Sử dụng Row để đặt tiêu đề và giá trị cạnh nhau
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (totalValue != null)
            Consumer( // Dùng Consumer để lấy formatter và settings
              builder: (context, ref, child) {
                final settings = ref.watch(profileProvider);
                final formatter = ref.read(numberFormattingServiceProvider);
                return Text(
                  formatter.formatPrice(
                    price: totalValue, 
                    currency: settings.currency, 
                    formatType: settings.numberFormat
                  ),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
            ),
        ],
      ),
    ),
  );
}

  // 2. Widget cho danh sách cuộn ngang "Most-Loved Pieces"
  Widget _buildMostWornList(List<ItemInsight> insights) {
    if (insights.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: insights.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final insight = insights[index];
            return SizedBox(
              width: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(
                        File(insight.item.thumbnailPath ?? insight.item.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    insight.item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${insight.wearCount} wears',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  // 3. Widget cho lưới "Smartest Investments"
  Widget _buildBestValueGrid(List<ItemInsight> insights) {
    if (insights.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.builder(
        itemCount: insights.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final insight = insights[index];
          return _BestValueItemCard(insight: insight);
        },
      ),
    );
  }

  // 4. Widget cho chồng thẻ "Forgotten Items" (sẽ được nâng cấp sau)
  Widget _buildForgottenItemsStack(BuildContext context, List<ItemInsight> insights) {
  if (insights.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

  return SliverList.separated(
    itemCount: insights.length,
    separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16, height: 1),
    itemBuilder: (context, index) {
      final insight = insights[index];
      return Consumer(
        builder: (context, ref, child) {
          return ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: Image.file(File(insight.item.thumbnailPath ?? insight.item.imagePath), fit: BoxFit.contain),
            ),
            title: Text(insight.item.name),
            subtitle: const Text('Not worn yet. Give it a try!'),
            trailing: TextButton(
              onPressed: () {
                ref.read(calendarProvider.notifier).logWearForDate(
                  DateTime.now(), 
                  {insight.item.id},
                  SelectionType.items
                );
                
                ref.read(notificationServiceProvider).showBanner(
                  message: 'Added "${insight.item.name}" to today\'s journal!',
                  type: NotificationType.success,
                );
              },
              // --- BẮT ĐẦU SỬA LỖI Ở ĐÂY ---
              // Di chuyển style và child ra khỏi onPressed
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                foregroundColor: Theme.of(context).colorScheme.primary,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Wear Today', style: TextStyle(fontWeight: FontWeight.bold)),
              // --- KẾT THÚC SỬA LỖI ---
            ),
          );
        },
      );
    },
  );
}

  // 5. Widget cho phân tích danh mục
  Widget _buildCategoryAnalysis(BuildContext context, ClosetInsights insights) {
    final sortedEntries = insights.valueByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    if (sortedEntries.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.builder(
        itemCount: sortedEntries.length,
        itemBuilder: (context, index) {
          final entry = sortedEntries[index];
          final percentage = (entry.value / insights.totalValue * 100);
          return _CategoryProgressRow(
            category: entry.key,
            percentage: percentage,
            value: entry.value,
          );
        },
      ),
    );
  }
}


// --- CÁC WIDGET THÀNH PHẦN NHỎ HƠN ---

class _BestValueItemCard extends ConsumerWidget {
  final ItemInsight insight;
  const _BestValueItemCard({required this.insight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(profileProvider);
    final formatter = ref.read(numberFormattingServiceProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      // Stack cho phép các widget xếp chồng lên nhau
      child: Stack(
        fit: StackFit.expand, // Làm cho các con trong Stack lấp đầy Card
        children: [
          // LỚP 1: HÌNH ẢNH NỀN
          Image.file(
            File(insight.item.thumbnailPath ?? insight.item.imagePath),
            fit: BoxFit.cover, // Luôn lấp đầy khung mà không bị méo
            errorBuilder: (ctx, err, stack) => const Icon(Icons.error),
          ),

          // LỚP 2: LỚP PHỦ GRADIENT ĐỂ CHỮ DỄ ĐỌC
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80, // Chiều cao của dải gradient
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha:0.7),
                    Colors.black.withValues(alpha:0.0),
                  ],
                ),
              ),
            ),
          ),

          // LỚP 3: NỘI DUNG VĂN BẢN
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Chữ màu trắng
                    shadows: [Shadow(blurRadius: 2, color: Colors.black54)], // Đổ bóng cho dễ đọc
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatter.formatPrice(
                    price: insight.costPerWear,
                    currency: settings.currency,
                    formatType: settings.numberFormat,
                  )}/wear',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, // Dùng màu xanh chủ đạo
                    fontWeight: FontWeight.w600,
                    fontSize: 13
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryProgressRow extends ConsumerWidget {
  final String category;
  final double percentage;
  final double value;

  const _CategoryProgressRow({
    required this.category,
    required this.percentage,
    required this.value,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(profileProvider);
    final formatter = ref.read(numberFormattingServiceProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                formatter.formatPrice(
                  price: value,
                  currency: settings.currency,
                  formatType: settings.numberFormat,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}