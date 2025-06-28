// lib/screens/pages/home_page.dart
import 'dart:io';

import 'package:dotted_border/dotted_border.dart'; // Sẽ cần thêm package này
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
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
import 'package:mincloset/helpers/weather_helper.dart';

final recentItemsProvider =
    FutureProvider.autoDispose<List<ClothingItem>>((ref) async {
  // Theo dõi trigger để làm mới provider khi item thay đổi
  ref.watch(itemChangedTriggerProvider); 
  
  final itemRepo = ref.watch(clothingItemRepositoryProvider);
  
  // Lấy kết quả Either từ repository
  final result = await itemRepo.getRecentItems(5);

  // Xử lý kết quả Either
  return result.fold(
    // (Left) Nếu thất bại, throw Exception để widget .when(error:..) bắt được
    (failure) => throw Exception(failure.message),
    // (Right) Nếu thành công, trả về danh sách items
    (items) => items,
  );
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
              label: 'Create new outfits',
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
                            ref.read(itemChangedTriggerProvider.notifier).state++;
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
  // Đọc trạng thái từ profileProvider để lấy cài đặt mới
  final profileState = ref.watch(profileProvider);

  final String backgroundImagePath = WeatherHelper.getBackgroundImageForWeather(
    state.weather?['weather'][0]['icon'] as String?,
  );

  return Card(
    elevation: 0,
    color: Colors.transparent,
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: theme.colorScheme.outline,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== HEADER SECTION =====
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
          child: Stack(
            children: [
              // LỚP 1: HÌNH ẢNH NỀN (ĐÃ ĐƯỢC THAY ĐỔI)
              Positioned.fill(
                // <<< THAY ĐỔI CỐT LÕI NẰM Ở ĐÂY >>>
                child: profileState.showWeatherImage
                    ? Image.asset( // Nếu BẬT, hiện ảnh
                        backgroundImagePath,
                        fit: BoxFit.cover,
                      )
                    : Container( // Nếu TẮT, hiện màu nền
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
              ),
              // LỚP 2: LỚP GRADIENT (GIỮ NGUYÊN)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        // Điều chỉnh để gradient đẹp hơn trên nền màu
                        profileState.showWeatherImage ? Colors.white : theme.colorScheme.surfaceContainerHighest,
                        profileState.showWeatherImage
                            ? Colors.white.withValues(alpha:0.0)
                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.0),
                      ],
                      stops: const [0.0, 0.8],
                    ),
                  ),
                ),
              ),

              // LỚP 3: NỘI DUNG (GIỮ NGUYÊN)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 4, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.weather?['name'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                              child: Text(
                                state.weather!['name'] as String,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
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
                    ElevatedButton.icon(
                      key: const ValueKey('new_suggestion_button'),
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('Get Suggestion'),
                      onPressed: state.isLoading ? null : notifier.getNewSuggestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha:0.4),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        side: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

          // ===== PHẦN 2: NỘI DUNG GỢI Ý (NỀN TRẮNG) =====
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: // Phần logic hiển thị kết quả gợi ý không thay đổi
            state.isLoading
              ? const Center(heightFactor: 5, child: CircularProgressIndicator())
              : state.suggestionResult != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSuggestionPlaceholder(state.suggestionResult!),
                    const SizedBox(height: 16),
                    Text(
                      state.suggestionResult!.outfitName,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.suggestionResult!.reason,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit & Save'),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.outfitBuilder, arguments: state.suggestionResult);
                        },
                      ),
                    ),
                  ],
                )
              : Center(
                  heightFactor: 5,
                  child: Text(
                    state.errorMessage ?? 'Tap "Get Suggestions" to see outfit recommendations!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  ),
                ),
          ),
          
          if (state.suggestionTimestamp != null && state.suggestionResult != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Last updated: ${DateFormat('HH:mm, dd/MM/yyyy').format(state.suggestionTimestamp!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSuggestionPlaceholder(SuggestionResult result) {
    // Hàm nhỏ để tạo một placeholder
    Widget singlePlaceholder(ClothingItem? item, {double? width, double? height}) {
      if (item == null) {
        // >>> PHẦN SỬA LỖI CUỐI CÙNG NẰM Ở ĐÂY <<<
        return DottedBorder(
          options: RoundedRectDottedBorderOptions(
            // XÓA DÒNG BÁO LỖI "borderType: BorderType.RRect,"
            radius: const Radius.circular(8),
            color: Colors.grey.shade400,
            strokeWidth: 1.5,
            dashPattern: const [6, 4],
          ),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      return Image.file(
        File(item.imagePath),
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, stack) => const Icon(Icons.error_outline),
      );
    }

    // Phần còn lại của hàm không thay đổi
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Stack(
          children: [
            // Outerwear (áo khoác) - nằm dưới cùng
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: singlePlaceholder(result.composition['outerwear']),
            ),
            // Topwear (áo)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              height: 150,
              child: singlePlaceholder(result.composition['topwear']),
            ),
            // Bottomwear (quần/váy)
            Positioned(
              bottom: 60,
              left: 40,
              right: 40,
              height: 180,
              child: singlePlaceholder(result.composition['bottomwear']),
            ),
            // Footwear (giày)
            Positioned(
              bottom: 10,
              left: 60,
              right: 60,
              height: 60,
              child: singlePlaceholder(result.composition['footwear']),
            ),
            // Accessories (phụ kiện)
            Positioned(
              top: 10,
              right: 10,
              width: 50,
              height: 50,
              child: singlePlaceholder(result.composition['accessories']),
            ),
          ],
        ),
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