// file: lib/screens/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/services/suggestion_service.dart';
import 'package:mincloset/services/weather_service.dart';
import 'package:mincloset/widgets/recent_item_card.dart';
import 'package:mincloset/widgets/section_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mincloset/utils/logger.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Các biến trạng thái cho cả giao diện
  bool _isPromoCardDismissed = false;
  String? _aiSuggestion;
  bool _isLoadingSuggestion = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Gọi hàm tải dữ liệu chính
  }

  // Hàm tải tất cả dữ liệu cần thiết cho trang Home khi khởi động
  Future<void> _loadInitialData() async {
    // Chạy song song việc load trạng thái thẻ và lấy gợi ý
    await Future.wait([
      _loadDismissedState(),
      _fetchSuggestion(),
    ]);
  }

  Future<void> _loadDismissedState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isPromoCardDismissed = prefs.getBool('promoCardDismissed') ?? false;
      });
    }
  }

  // Hàm chính để lấy gợi ý từ AI
  Future<void> _fetchSuggestion() async {
    // Nếu đang không loading thì set lại để hiển thị vòng xoay
    if (!_isLoadingSuggestion) {
      setState(() { _isLoadingSuggestion = true; });
    }

    try {
      final items = await DBHelper.getData('clothing_items')
          .then((data) => data.map((item) => ClothingItem.fromMap(item)).toList());

      if (items.isEmpty) {
        throw Exception('Tủ đồ trống.');
      }

      final weatherData = await WeatherService.getWeather('Da Nang');
      final suggestion = await SuggestionService.getOutfitSuggestion(
          weather: weatherData, items: items);
      
      if(mounted) {
        setState(() {
          _aiSuggestion = suggestion;
        });
      }
    } catch (e, s) { // Thêm 's' để lấy StackTrace
      logger.w(
        'Không thể lấy gợi ý', // Dùng warning thay vì error vì đây có thể là lỗi do người dùng (tủ đồ trống)
        error: e,
        stackTrace: s,
      );
      if (mounted) {
        setState(() {
          _aiSuggestion = e.toString().contains('Tủ đồ trống')
              ? 'Hãy thêm đồ vào tủ để nhận gợi ý.'
              : 'Không thể nhận gợi ý lúc này.';
        });
      }
    } finally {
      if(mounted) {
        setState(() {
          _isLoadingSuggestion = false;
        });
      }
    }
  }

  Future<void> _dismissPromoCard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('promoCardDismissed', true);
    setState(() {
      _isPromoCardDismissed = true;
    });
  }

  Future<List<ClothingItem>> _loadRecentItems() async {
    // 1. Lấy dữ liệu thô (List<Map>) từ CSDL
    final dataList = await DBHelper.getRecentItems(5);
    
    // 2. Dùng hàm map để chuyển đổi từng Map thành một đối tượng ClothingItem
    //    và trả về một danh sách các đối tượng ClothingItem hoàn chỉnh.
    return dataList
        .map((itemMap) => ClothingItem.fromMap(itemMap))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar tùy chỉnh, không có background, chỉ có nội dung
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _buildHeader(),
        toolbarHeight: 80,
      ),
      body: RefreshIndicator( // Thêm chức năng kéo để làm mới
        onRefresh: _fetchSuggestion,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isPromoCardDismissed) const SizedBox(height: 16),
              if (!_isPromoCardDismissed) _buildPromoCard(),
              const SizedBox(height: 32),
              _buildAiStylistSection(),
              const SizedBox(height: 32),
              _buildRecentlyAddedSection(),
              const SizedBox(height: 32),
              // --- THẺ GỢI Ý HÔM NAY ---
              _buildTodaysSuggestionCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Widget cho Thẻ Gợi ý hôm nay
  Widget _buildTodaysSuggestionCard() {
    return Column(
      children: [
        SectionHeader(title: 'Gợi ý hôm nay', onSeeAll: (){}),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16)
          ),
          child: _isLoadingSuggestion
            ? const Center(child: CircularProgressIndicator())
            : Text(
                _aiSuggestion ?? 'Đã có lỗi xảy ra.',
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
        )
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xin chào,', style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text('MinVN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined, size: 28),
        ),
      ],
    );
  }

  Widget _buildPromoCard() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 40, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade200, Colors.purple.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thêm 30 món đồ và nhận gợi ý cho ngày mai!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: 1 / 30, backgroundColor: Colors.white.withAlpha(77), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), borderRadius: BorderRadius.circular(10)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white), child: const Text('Thêm đồ')),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: _dismissPromoCard,
          ),
        ),
      ],
    );
  }

  Widget _buildAiStylistSection() {
    return Column(
      children: [
        const SectionHeader(title: 'AI Stylist'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade400,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white),
                    Text('Bắt đầu phối đồ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.history, color: Colors.black),
                    Text('Lịch sử', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentlyAddedSection() {
    return Column(
      children: [
        SectionHeader(
          title: 'Đã thêm gần đây',
          onSeeAll: () {},
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: FutureBuilder<List<ClothingItem>>(
            future: _loadRecentItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildAddFirstItemButton();
              }
              final items = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length + 1,
                itemBuilder: (ctx, index) {
                  if (index == 0) {
                    return _buildAddFirstItemButton();
                  }
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

  Widget _buildAddFirstItemButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: const Center(
          child: Icon(Icons.add, size: 40, color: Colors.grey),
        ),
      ),
    );
  }
}