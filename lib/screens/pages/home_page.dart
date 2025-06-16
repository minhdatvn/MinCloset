// lib/screens/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/home_page_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/screens/pages/outfits_hub_page.dart';
import 'package:mincloset/widgets/recent_item_card.dart';
import 'package:mincloset/widgets/section_header.dart'; // <<< THAY ĐỔI IMPORT

// Provider này chỉ phục vụ cho việc lấy các món đồ đã thêm gần đây
final recentItemsProvider = FutureProvider.autoDispose<List<ClothingItem>>((ref) async {
  final dbHelper = ref.watch(dbHelperProvider);
  final itemsData = await dbHelper.getRecentItems(5);
  return itemsData.map((map) => ClothingItem.fromMap(map)).toList();
});


class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: _buildHeader(),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPromoCard(),
            const SizedBox(height: 32),
            _buildAiStylistSection(context),
            const SizedBox(height: 32),
            _buildRecentlyAddedSection(context, ref),
            const SizedBox(height: 32),
            SectionHeader(
              title: 'Gợi ý hôm nay',
            ),
            const SizedBox(height: 16),
            _buildTodaysSuggestionCard(context, homeState, homeNotifier),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xin chào,', style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text('MinVN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        Spacer(),
        IconButton(onPressed: null, icon: Icon(Icons.notifications_outlined, size: 28)),
      ],
    );
  }

  Widget _buildPromoCard() {
    return Card(
      elevation: 0,
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thêm 30 món đồ và nhận gợi ý cho ngày mai!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 1 / 30,
              backgroundColor: Colors.deepPurple.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiStylistSection(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: 'AI Stylist'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (ctx) => const OutfitsHubPage())),
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(12),
                  decoration:
                      BoxDecoration(color: Colors.blue.shade400, borderRadius: BorderRadius.circular(16)),
                  child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white),
                        Text('Bắt đầu phối đồ',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      ]),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                // <<< THAY ĐỔI Ở ĐÂY: Sửa SavedOutfitsPage thành OutfitsHubPage
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (ctx) => const OutfitsHubPage())),
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(12),
                  decoration:
                      BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                  child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.collections_bookmark_outlined, color: Colors.black),
                        Text('Bộ đồ đã lưu',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                      ]),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentlyAddedSection(BuildContext context, WidgetRef ref) {
    final recentItemsAsync = ref.watch(recentItemsProvider);
    return Column(
      children: [
        SectionHeader(title: 'Đã thêm gần đây', onSeeAll: () {}),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: recentItemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Text('Không thể tải...'),
            data: (items) {
              if (items.isEmpty) {
                return _buildAddFirstItemButton(context);
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length + 1,
                itemBuilder: (ctx, index) {
                  if (index == 0) return _buildAddFirstItemButton(context);
                  final item = items[index - 1];
                  return RecentItemCard(item: item);
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAddFirstItemButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => const AddItemScreen()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade200),
        child: const Center(child: Icon(Icons.add, size: 40, color: Colors.grey)),
      ),
    );
  }


  Widget _buildTodaysSuggestionCard(BuildContext context, HomePageState state, HomePageNotifier notifier) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: (state.isLoading && state.weather == null)
                    ? const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))
                    : (state.weather != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.weather!['name'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(_getWeatherIcon(state.weather!['weather'][0]['icon']), color: Colors.orange.shade700, size: 32),
                                const SizedBox(width: 8),
                                Text('${state.weather!['main']['temp'].toStringAsFixed(0)}°C', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox(height: 60, child: Center(child: Text("Không có dữ liệu thời tiết.")))
                    )
              ),
              TextButton.icon(
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Gợi ý mới'),
                onPressed: state.isLoading ? null : notifier.getNewSuggestion,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),

          const Divider(height: 24, thickness: 0.5),

          if (state.isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: CircularProgressIndicator(),
            ))
          else
            Text(
              state.suggestion ?? 'Nhấn nút "Gợi ý mới" để MinCloset tư vấn cho bạn nhé!',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          
          if (state.suggestionTimestamp != null) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Cập nhật lúc: ${DateFormat('HH:mm, dd/MM/yyyy').format(state.suggestionTimestamp!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n': return Icons.wb_sunny;
      case '02d':
      case '02n': return Icons.cloud_outlined;
      case '03d':
      case '03n':
      case '04d':
      case '04n': return Icons.cloud;
      case '09d':
      case '09n': return Icons.grain;
      case '10d':
      case '10n': return Icons.water_drop;
      case '11d':
      case '11n': return Icons.thunderstorm;
      case '13d':
      case '13n': return Icons.ac_unit;
      case '50d':
      case '50n': return Icons.foggy;
      default: return Icons.thermostat;
    }
  }
}