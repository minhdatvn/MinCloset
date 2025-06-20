// lib/screens/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/home_page_notifier.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/screens/analysis_loading_screen.dart';
import 'package:mincloset/screens/pages/outfit_builder_page.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/screens/pages/outfits_hub_page.dart';
import 'package:mincloset/widgets/action_card.dart';
import 'package:mincloset/widgets/recent_item_card.dart';
import 'package:mincloset/widgets/section_header.dart';
import 'package:mincloset/widgets/stats_overview_card.dart';

final recentItemsProvider =
    FutureProvider.autoDispose<List<ClothingItem>>((ref) async {
  ref.watch(itemAddedTriggerProvider);

  final itemRepo = ref.watch(clothingItemRepositoryProvider);
  return itemRepo.getRecentItems(5);
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _pickAndAnalyzeImage(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
       if (navigator.mounted) {
         final itemWasAdded = await navigator.push<bool>(
            MaterialPageRoute(builder: (ctx) => AnalysisLoadingScreen(images: [pickedFile])),
         );
         
         if (itemWasAdded == true) {
            ref.read(itemAddedTriggerProvider.notifier).state++;
         }
       }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: _buildHeader(context, ref),
        toolbarHeight: 80,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recentItemsProvider);
          await homeNotifier.getNewSuggestion();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatsOverviewCard(
                totalItems: profileState.totalItems,
                totalClosets: profileState.totalClosets,
                totalOutfits: profileState.totalOutfits,
              ),
              const SizedBox(height: 32),
              _buildAiStylistSection(context),
              const SizedBox(height: 32),
              _buildRecentlyAddedSection(context, ref),
              const SizedBox(height: 32),
              const SectionHeader(
                title: 'Gợi ý hôm nay',
              ),
              const SizedBox(height: 16),
              _buildTodaysSuggestionCard(context, homeState, homeNotifier),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(profileProvider.select((state) => state.userName));
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Xin chào,',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text(userName ?? 'MinVN',
                style: Theme.of(context).appBarTheme.titleTextStyle),
          ],
        ),
        const Spacer(),
        IconButton(
            onPressed: () { /* TODO: Implement notifications */ },
            icon: const Icon(Icons.notifications_outlined, size: 28)),
      ],
    );
  }

  Widget _buildAiStylistSection(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: 'Xưởng phối đồ'),
        const SizedBox(height: 16),
        Row(
          children: [
            ActionCard(
              label: 'Bắt đầu phối đồ',
              icon: Icons.auto_awesome_outlined,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => const OutfitBuilderPage())),
            ),
            const SizedBox(width: 16),
            ActionCard(
              label: 'Bộ đồ đã lưu',
              icon: Icons.collections_bookmark_outlined,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => const OutfitsHubPage())),
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
        SectionHeader(
          title: 'Đã thêm gần đây',
          seeAllText: 'Xem tất cả',
          onSeeAll: () {
            ref.read(mainScreenIndexProvider.notifier).state = 1;
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: recentItemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Text('Không thể tải...'),
            data: (items) {
              if (items.isEmpty) {
                return _buildAddFirstItemButton(context, ref);
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length + 1,
                itemBuilder: (ctx, index) {
                  if (index == 0) {
                    return _buildAddFirstItemButton(context, ref);
                  }
                  final item = items[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: SizedBox(
                      width: 120 * (3 / 4),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (context) => AddItemScreen(itemToEdit: item),
                            ),
                          );
                        },
                        child: RecentItemCard(item: item),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAddFirstItemButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () => _pickAndAnalyzeImage(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120 * (3/4), 
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Icon(Icons.add, size: 40, color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }

  Widget _buildTodaysSuggestionCard(BuildContext context, HomePageState state, HomePageNotifier notifier) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
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
                  foregroundColor: theme.colorScheme.primary,
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