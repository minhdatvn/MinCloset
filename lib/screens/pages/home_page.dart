// lib/screens/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/database_providers.dart'; // Cần provider này để lấy recent items
import 'package:mincloset/providers/home_page_notifier.dart';
import 'package:mincloset/providers/home_page_state.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/screens/pages/outfit_builder_page.dart';
import 'package:mincloset/screens/pages/saved_outfits_page.dart';
import 'package:mincloset/widgets/recent_item_card.dart';
import 'package:mincloset/widgets/section_header.dart';

// 1. CHUYỂN THÀNH CONSUMERWIDGET
// Widget không còn lưu giữ trạng thái (state) nữa.
// Nó chỉ nhận dữ liệu và hiển thị.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  // 2. NHẬN WIDGETREF TRONG HÀM BUILD
  // `ref` là công cụ để giao tiếp với các provider
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. LẤY STATE VÀ NOTIFIER TỪ PROVIDER
    // - ref.watch: "Theo dõi" trạng thái. Khi state thay đổi, widget này sẽ build lại.
    final homeState = ref.watch(homeProvider);
    // - ref.read: "Đọc" notifier. Dùng để gọi các hàm bên trong notifier.
    final homeNotifier = ref.read(homeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: _buildHeader(),
        toolbarHeight: 80,
      ),
      // 4. MỌI LOGIC TRONG UI ĐỀU DỰA VÀO `homeState`
      body: RefreshIndicator(
        // Khi người dùng kéo để làm mới, chỉ cần gọi hàm từ notifier
        onRefresh: () => homeNotifier.fetchSuggestion(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          // Dựa vào `homeState` để quyết định hiển thị gì
          child: _buildBody(context, ref, homeState),
        ),
      ),
    );
  }

  // Widget con để build phần body, giúp hàm build chính gọn hơn
  Widget _buildBody(BuildContext context, WidgetRef ref, HomePageState state) {
    // Nếu có lỗi, hiển thị thông báo lỗi
    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(homeProvider.notifier).fetchSuggestion(),
              child: const Text('Thử lại'),
            )
          ],
        ),
      );
    }

    // Các widget chính của trang
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPromoCard(), // Widget này không thay đổi
        const SizedBox(height: 32),
        _buildAiStylistSection(context), // Widget này không thay đổi
        const SizedBox(height: 32),
        _buildRecentlyAddedSection(ref), // Cần `ref` để đọc provider
        const SizedBox(height: 32),
        _buildTodaysSuggestionCard(state), // Cần `state` để hiển thị dữ liệu
        const SizedBox(height: 32),
      ],
    );
  }

  // Widget header không thay đổi
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

  // Widget thẻ promo không thay đổi
  Widget _buildPromoCard() {
    // Logic của thẻ này (dismiss) có thể được quản lý bằng một provider riêng
    // nhưng tạm thời giữ nguyên để đơn giản hóa
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

  // Widget AI Stylist không thay đổi
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
                    .push(MaterialPageRoute(builder: (ctx) => const OutfitBuilderPage())),
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
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (ctx) => const SavedOutfitsPage())),
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

  // Widget hiển thị các món đồ đã thêm gần đây
  Widget _buildRecentlyAddedSection(WidgetRef ref) {
    // Chúng ta có thể tạo một provider riêng cho recent items
    // Ở đây ta dùng lại provider đã có từ Bước 2 để lấy dữ liệu
    final recentItemsProvider = ref.watch(itemsInClosetProvider('')); // Giả sử có một hàm lấy tất cả

    return Column(
      children: [
        SectionHeader(title: 'Đã thêm gần đây', onSeeAll: () {}),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: recentItemsProvider.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Text('Không thể tải...'),
            data: (items) {
              if (items.isEmpty) return _buildAddFirstItemButton();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length + 1,
                itemBuilder: (ctx, index) {
                  if (index == 0) return _buildAddFirstItemButton();
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

  // Widget hiển thị gợi ý của hôm nay
  Widget _buildTodaysSuggestionCard(HomePageState state) {
    // Widget này giờ chỉ nhận `state` và hiển thị
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
      child: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.weather != null) ...[
                  Text(
                    state.weather!['name'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(_getWeatherIcon(state.weather!['weather'][0]['icon']),
                          color: Colors.orange.shade700, size: 32),
                      const SizedBox(width: 8),
                      Text('${state.weather!['main']['temp'].toStringAsFixed(0)}°C',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24, thickness: 0.5),
                ],
                Text(
                  state.suggestion ?? 'Chưa có gợi ý nào. Hãy nhấn nút làm mới!',
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
    );
  }

  // Các widget helper khác không thay đổi nhiều
  Widget _buildAddFirstItemButton() {
    return Builder(builder: (context) {
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
    });
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return Icons.wb_sunny;
      case '02d':
      case '02n':
        return Icons.cloud_outlined;
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return Icons.cloud;
      case '09d':
      case '09n':
        return Icons.grain;
      case '10d':
      case '10n':
        return Icons.water_drop;
      case '11d':
      case '11n':
        return Icons.thunderstorm;
      case '13d':
      case '13n':
        return Icons.ac_unit;
      case '50d':
      case '50n':
        return Icons.foggy;
      default:
        return Icons.thermostat;
    }
  }
}