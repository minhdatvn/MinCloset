// lib/screens/closet_insights_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/models/item_insight.dart';
import 'package:mincloset/domain/models/closet_insights.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/notifiers/closet_insights_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/theme/app_theme.dart';
import 'package:mincloset/widgets/stats_pie_chart.dart';

class ClosetInsightsScreen extends ConsumerWidget {
  const ClosetInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(closetInsightsProvider);
    final notifier = ref.read(closetInsightsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Closets Insights'),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.fetchInsights,
        child: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ClosetInsightsState state) {
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

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _FinancialOverview(insights: state.insights!),
        const SizedBox(height: 32),
        _PerformanceSection(
          title: "Smartest Investments",
          insights: state.insights!.bestValueItems,
          subtitleKey: 'Cost per Wear',
        ),
        const SizedBox(height: 32),
        _PerformanceSection(
          title: "Closet Orphans",
          insights: state.insights!.forgottenItems,
          subtitleKey: 'Original Price',
        ),
        const SizedBox(height: 32),
        _UsageStats(title: 'Most Worn Items', insights: state.insights!.mostWornItems),
      ],
    );
  }
}

// --- CÁC WIDGET HELPER ---

class _FinancialOverview extends ConsumerWidget {
  final ClosetInsights insights;
  const _FinancialOverview({required this.insights});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(profileProvider);
    final formatter = ref.read(numberFormattingServiceProvider);

    // --- BẮT ĐẦU SỬA LỖI VÀ TÁI CẤU TRÚC ---

    // Sắp xếp các danh mục theo giá trị giảm dần để hiển thị chú thích
    final sortedEntries = insights.valueByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    // Chỉ lấy 4 danh mục lớn nhất để hiển thị chú thích cho gọn
    final topEntries = sortedEntries.take(4);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Financial Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Center(
              child: Text(
                formatter.formatPrice(
                    price: insights.totalValue,
                    currency: settings.currency,
                    formatType: settings.numberFormat),
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            Center(child: Text('Total closet Value', style: Theme.of(context).textTheme.bodySmall)),
            
            if (insights.valueByCategory.isNotEmpty) ...[
              const SizedBox(height: 24),
              // Sử dụng Row để đặt biểu đồ và chú thích cạnh nhau
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // BIỂU ĐỒ TRÒN
                  Expanded(
                    flex: 2, // Cho biểu đồ chiếm 2 phần
                    child: SizedBox(
                      height: 60, // Đặt chiều cao cố định
                      child: StatsPieChart(
                        title: 'Value by Category',
                        showChartTitle: false, // Ẩn title mặc định
                        dataMap: insights.valueByCategory.map((key, value) => MapEntry(key, value.toInt())),
                        size: 60,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // KHU VỰC CHÚ THÍCH
                  Expanded(
                    flex: 3, // Cho chú thích chiếm 3 phần để có nhiều không gian hơn
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: topEntries.map((entry) {
                        final percentage = (entry.value / insights.totalValue * 100);
                        final color = AppChartColors.defaultChartColors[
                            sortedEntries.indexOf(entry) % AppChartColors.defaultChartColors.length];
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${entry.key} (${percentage.toStringAsFixed(0)}%)',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
    // --- KẾT THÚC SỬA LỖI ---
  }
}

class _PerformanceSection extends StatelessWidget {
  final String title;
  final String subtitleKey;
  final List<ItemInsight> insights;
  
  const _PerformanceSection({
    required this.title,
    required this.subtitleKey,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: insights.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final insight = insights[index];
              return _InsightItemCard(
                insight: insight,
                subtitleKey: subtitleKey,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InsightItemCard extends ConsumerWidget {
  final ItemInsight insight;
  final String subtitleKey;
  const _InsightItemCard({required this.insight, required this.subtitleKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(profileProvider);
    final formatter = ref.read(numberFormattingServiceProvider);
    
    String subtitleText;
    if (subtitleKey == 'Cost per Wear') {
      subtitleText = insight.costPerWear.isInfinite 
          ? 'N/A' 
          : formatter.formatPrice(
              price: insight.costPerWear, 
              currency: settings.currency, 
              formatType: settings.numberFormat
            );
    } else {
      subtitleText = formatter.formatPrice(
        price: insight.item.price!,
        currency: settings.currency,
        formatType: settings.numberFormat
      );
    }

    // --- BẮT-ĐẦU SỬA-LỖI ---
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần ảnh giữ-nguyên
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Card(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.zero,
              child: Image.file(
                File(insight.item.thumbnailPath ?? insight.item.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Bọc phần text trong Expanded và SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.item.name,
                    maxLines: 2, // Cho phép hiển-thị 2 dòng
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitleText,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Worn ${insight.wearCount} times',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    // --- KẾT-THÚC SỬA-LỖI ---
  }
}

class _UsageStats extends StatelessWidget {
  final String title;
  final List<ItemInsight> insights;
  const _UsageStats({required this.title, required this.insights});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            children: insights.map((insight) {
              return ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.file(
                    File(insight.item.thumbnailPath ?? insight.item.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
                title: Text(insight.item.name),
                trailing: Text('${insight.wearCount} wears'),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}