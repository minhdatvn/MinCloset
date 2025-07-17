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
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/log_wear_state.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/helpers/context_extensions.dart';

class ClosetInsightsScreen extends ConsumerWidget {
  const ClosetInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(closetInsightsProvider);
    final notifier = ref.read(closetInsightsProvider.notifier);
    final userName = ref.watch(profileProvider.select((s) => s.userName)) ?? context.l10n.home_userNameDefault;
    final l10n = context.l10n;
    final bool needsSimpleAppBar = state.errorMessage != null || (state.insights == null && !state.isLoading);
    
    return PageScaffold(
      appBar: needsSimpleAppBar
          ? AppBar(
              title: Text(l10n.insights_title),
            )
          : null, // Khi có dữ liệu, SliverAppBar bên trong sẽ được dùng
      body: RefreshIndicator(
        onRefresh: notifier.fetchInsights,
        child: _buildBody(context, ref, state, userName),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ClosetInsightsState state, String userName) {
    final l10n = context.l10n;
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popAndPushNamed(AppRoutes.calendar);
                  },
                  child: 
                    Text(
                    l10n.insights_goToJournal,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    if (state.insights == null) {
      return Center(child: Text(l10n.insights_noData));
    }

    return CustomScrollView(
      slivers: [
        _buildMagazineCover(context, userName, state.insights!),
        _buildSectionHeader(context, l10n.insights_mostLoved),
        _buildMostWornList(context, state.insights!.mostWornItems),
        _buildSectionHeader(context, l10n.insights_smartestInvestments),
        _buildBestValueList(context, ref, state.insights!.bestValueItems),
        _buildSectionHeader(context, l10n.insights_rediscoverCloset),
        _buildForgottenItemsStack(context, state.insights!.forgottenItems),
        _buildSectionHeader(
          context,
          l10n.insights_investmentFocus,
          totalValue: state.insights!.totalValue,
        ),
        _buildCategoryAnalysis(context, state.insights!),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }

  // --- CÁC WIDGET HELPER CHO TỪNG PHẦN ---

  Widget _buildMagazineCover(
      BuildContext context, String userName, ClosetInsights insights) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Builder(
        builder: (context) {
          final settings = context
              .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
          final showTitle =
              (settings?.currentExtent ?? 0) <= (settings?.minExtent ?? 0) + 1;

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: showTitle ? 1.0 : 0.0,
            child: Text(l10n.insights_title),
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
              'assets/images/insights/ins_bg.webp',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    theme.scaffoldBackgroundColor,
                    theme.scaffoldBackgroundColor.withValues(alpha:0.0),
                  ],
                  stops: const [0.0, 0.8],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.insights_exclusive,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.insights_journeyTitle(userName),
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
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      {double? totalValue}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (totalValue != null)
              Consumer(builder: (context, ref, child) {
                final settings = ref.watch(profileProvider);
                final formatter = ref.read(numberFormattingServiceProvider);
                return Text(
                  formatter.formatPrice(
                      price: totalValue,
                      currency: settings.currency,
                      formatType: settings.numberFormat),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                );
              }),
          ],
        ),
      ),
    );
  }

  // THAY ĐỔI 1: Hàm cho "Most-Loved Pieces" giờ là ListView cuộn ngang
  Widget _buildMostWornList(BuildContext context, List<ItemInsight> insights) {
    final l10n = context.l10n;
    final mostWornItems =
        insights.where((insight) => insight.wearCount > 0).toList();

    if (mostWornItems.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    l10n.insights_mostWorn_noData,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.calendar);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(l10n.insights_goToJournal),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 230, // Chiều cao của khu vực cuộn ngang
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: mostWornItems.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final insight = mostWornItems[index];
            return SizedBox(
              width: 160, // Chiều rộng của mỗi thẻ
              child: _InsightItemCard(
                insight: insight,
                subtitle: 
                  Text(l10n.insights_wears(insight.wearCount),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBestValueList(
      BuildContext context, WidgetRef ref, List<ItemInsight> insights) {
    final l10n = context.l10n; // Lấy l10n một lần

    if (insights.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    l10n.insights_bestValue_noData, // Sử dụng l10n
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(mainScreenIndexProvider.notifier).state = 1;
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    icon: const Icon(Icons.edit_note_outlined),
                    label: Text(l10n.insights_addPrices), // Sử dụng l10n
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 230,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: insights.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final insight = insights[index];
            return SizedBox(
              width: 160,
              child: Consumer(builder: (context, ref, child) {
                final settings = ref.watch(profileProvider);
                final formatter = ref.read(numberFormattingServiceProvider);
                
                // 1. Tính toán và định dạng giá tiền trước
                final formattedPrice = formatter.formatPrice(
                  price: insight.costPerWear,
                  currency: settings.currency,
                  formatType: settings.numberFormat,
                );

                // 2. Truyền giá trị đã định dạng vào hàm l10n
                return _InsightItemCard(
                  insight: insight,
                  subtitle: Text(
                    l10n.insights_costPerWear(formattedPrice),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForgottenItemsStack(BuildContext context, List<ItemInsight> insights) {
    final l10n = context.l10n;
    if (insights.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList.separated(
      itemCount: insights.length,
      separatorBuilder: (context, index) =>
          const Divider(indent: 16, endIndent: 16, height: 1),
      itemBuilder: (context, index) {
        final insight = insights[index];
        return Consumer(
          builder: (context, ref, child) {
            return ListTile(
              leading: SizedBox(
                width: 50,
                height: 50,
                child: Image.file(
                    File(insight.item.thumbnailPath ?? insight.item.imagePath),
                    fit: BoxFit.contain),
              ),
              title: Text(insight.item.name),
              subtitle: Text(l10n.insights_forgottenItem_subtitle),
              trailing: TextButton(
                onPressed: () async {
                  final success =
                      await ref.read(calendarProvider.notifier).logWearForDate(
                            DateTime.now(),
                            {insight.item.id},
                            SelectionType.items,
                          );

                  if (!context.mounted) return;

                  if (success) {
                    ref.read(notificationServiceProvider).showBanner(
                          message: l10n.insights_wearToday_success(insight.item.name),
                          type: NotificationType.success,
                        );
                    ref.read(closetInsightsProvider.notifier).fetchInsights();
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(l10n.insights_wearToday,
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryAnalysis(
      BuildContext context, ClosetInsights insights) {
    final sortedEntries = insights.valueByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedEntries.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

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

class _InsightItemCard extends StatelessWidget {
  final ItemInsight insight;
  final Widget subtitle;

  const _InsightItemCard({
    required this.insight,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // --- BẮT ĐẦU SỬA ĐỔI TẠI ĐÂY ---
            // 1. Thêm một Container nền trắng
            Container(
              color: Colors.white,
              // 2. Thêm Padding để ảnh không bị dính sát vào viền
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.file(
                  File(insight.item.thumbnailPath ?? insight.item.imagePath),
                  // 3. Thay đổi thuộc tính fit thành .contain
                  fit: BoxFit.contain, 
                  errorBuilder: (ctx, err, stack) => const Icon(Icons.error),
                ),
              ),
            ),
            // --- KẾT THÚC SỬA ĐỔI ---

            // Các lớp phủ (gradient và text) không thay đổi
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
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
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
                    ),
                  ),
                  const SizedBox(height: 4),
                  subtitle,
                ],
              ),
            ),
          ],
        ),
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
              Text(category,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
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