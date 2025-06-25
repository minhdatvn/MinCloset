// lib/screens/pages/home_page.dart

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/notifiers/home_page_notifier.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/home_page_state.dart';
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

// <<< THAY ĐỔI 1: Chuyển thành ConsumerStatefulWidget >>>
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {

  // <<< THAY ĐỔI 2: Kích hoạt notifier trong initState >>>
  @override
  void initState() {
    super.initState();
    // Đảm bảo notifier được khởi tạo và bắt đầu tải dữ liệu khi widget được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ref được truy cập thông qua `this.ref` trong State
    final homeState = ref.watch(homeProvider);
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: _buildHeader(context, ref),
        toolbarHeight: 80,
      ),
      body: RefreshIndicator(
        onRefresh: () async => await ref.read(homeProvider.notifier).refreshWeatherOnly(), //Khi làm mới chỉ lấy thông tin thời tiết
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
              _buildAiStylistSection(context, ref),
              const SizedBox(height: 32),
              _buildRecentlyAddedSection(context, ref),
              const SizedBox(height: 32),
              const SectionHeader(
                title: 'Outfit Suggestions',
              ),
              const SizedBox(height: 16),
              // Truyền ref vào hàm build card
              _buildTodaysSuggestionCard(context, ref, homeState),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Các hàm build UI con không thay đổi, chỉ cần truyền ref nếu cần
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(profileProvider.select((state) => state.userName));
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hello,',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text(userName ?? 'User',
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

  Widget _buildAiStylistSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SectionHeader(title: 'Outfit Studio'),
        const SizedBox(height: 16),
        Row(
          children: [
            ActionCard(
              label: 'Create a new outfit',
              icon: Icons.auto_awesome_outlined,
              onTap: () => Navigator.pushNamed(context, AppRoutes.outfitBuilder),
            ),
            const SizedBox(width: 16),
            ActionCard(
              label: 'Saved outfits',
              icon: Icons.collections_bookmark_outlined,
              onTap: () => ref.read(mainScreenIndexProvider.notifier).state = 2,
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
          title: 'Latest Items',
          seeAllText: 'View all',
          onSeeAll: () {
            ref.read(mainScreenIndexProvider.notifier).state = 1;
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: recentItemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Center(child: Text('Cannot load items...')),
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    "Your latest items will appear here.",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (ctx, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: SizedBox(
                      width: 120 * (3 / 4),
                      child: GestureDetector(
                        onTap: () async {
                          final wasChanged = await Navigator.pushNamed(
                            context, 
                            AppRoutes.addItem, 
                            arguments: ItemNotifierArgs(tempId: item.id, itemToEdit: item)
                          );
                          if (wasChanged == true) {
                            ref.read(itemAddedTriggerProvider.notifier).state++;
                          }
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
  
  // <<< THAY ĐỔI 3: Thêm tham số ref và sửa đổi logic hiển thị địa điểm >>>
  Widget _buildTodaysSuggestionCard(BuildContext context, WidgetRef ref, HomePageState state) {
    final theme = Theme.of(context);
    final notifier = ref.read(homeProvider.notifier);

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hiển thị tên địa điểm nếu có
                    if (state.weather?['name'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          state.weather!['name'] as String,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    
                    // Hiển thị thông tin thời tiết
                    (state.weather != null
                      ? Row(
                          children: [
                            Icon(_getWeatherIcon(state.weather!['weather'][0]['icon'] as String), color: Colors.orange.shade700, size: 32),
                            const SizedBox(width: 8),
                            Text('${(state.weather!['main']['temp'] as num).toStringAsFixed(0)}°C', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          ],
                        )
                      : const SizedBox(height: 40, child: Center(child: Text("Weather data unavailable.")))
                    )
                  ],
                ),
              ),
              TextButton.icon(
                key: const ValueKey('new_suggestion_button'),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Get Suggestion'),
                onPressed: state.isLoading ? null : notifier.getNewSuggestion,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),

          const Divider(height: 24, thickness: 0.5),

          Stack(
            alignment: Alignment.center,
            children: [
              // Lớp 1: AnimatedTextKit luôn được build, nhưng có thể bị làm mờ
              AnimatedOpacity(
                opacity: state.isLoading ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedTextKit(
                  key: ValueKey(state.suggestionId),
                  isRepeatingAnimation: false, // Thêm dòng này để chắc chắn nó chỉ chạy 1 lần
                  animatedTexts: [
                    TypewriterAnimatedText(
                      state.suggestion ?? 'Tap "Get Suggestion" to see outfit recommendations!',
                      textStyle: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                      speed: const Duration(milliseconds: 20),
                    ),
                  ],
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
              ),

              // Lớp 2: Vòng xoay loading chỉ hiển thị khi isLoading = true
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(),
                )
            ],
          ),
          
          if (state.suggestionTimestamp != null) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Last updated: ${DateFormat('HH:mm, dd/MM/yyyy').format(state.suggestionTimestamp!)}',
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
      case '01d': case '01n': return Icons.wb_sunny;
      case '02d': case '02n': return Icons.cloud_outlined;
      case '03d': case '03n': case '04d': case '04n': return Icons.cloud;
      case '09d': case '09n': return Icons.grain;
      case '10d': case '10n': return Icons.water_drop;
      case '11d': case '11n': return Icons.thunderstorm;
      case '13d': case '13n': return Icons.ac_unit;
      case '50d': case '50n': return Icons.foggy;
      default: return Icons.thermostat;
    }
  }
}