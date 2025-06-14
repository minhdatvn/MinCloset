// file: lib/screens/pages/home_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/services/suggestion_service.dart';
import 'package:mincloset/services/weather_service.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:mincloset/widgets/recent_item_card.dart';
import 'package:mincloset/widgets/section_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Các biến trạng thái của trang
  bool _isPromoCardDismissed = false;
  String? _aiSuggestion;
  DateTime? _suggestionTimestamp;
  bool _isLoadingSuggestion = false; // Bắt đầu với false để không hiển thị loading khi mới vào
  Map<String, dynamic>? _currentWeather;

  @override
  void initState() {
    super.initState();
    // Trong initState, chỉ làm các việc thật nhẹ nhàng
    _loadDismissedState();
    _loadLastSuggestionFromCache();

    // Lên lịch để chạy _fetchSuggestion SAU KHI frame đầu tiên được vẽ xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Chỉ fetch gợi ý mới nếu chưa có gợi ý nào được load từ cache
      if (_aiSuggestion == null) {
        _fetchSuggestion();
      }
    });
  }

  // Đọc trạng thái đã lưu của thẻ khuyến mãi
  Future<void> _loadDismissedState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isPromoCardDismissed = prefs.getBool('promoCardDismissed') ?? false;
      });
    }
  }

  // Hàm này chỉ đọc từ SharedPreferences, rất nhanh
  Future<void> _loadLastSuggestionFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _aiSuggestion = prefs.getString('last_suggestion_text');
        final timestampString = prefs.getString('last_suggestion_timestamp');
        if (timestampString != null) {
          _suggestionTimestamp = DateTime.parse(timestampString);
        }
      });
    }
  }

  // Hàm chính để lấy gợi ý từ AI
  Future<void> _fetchSuggestion() async {
    if (!_isLoadingSuggestion) {
      setState(() { _isLoadingSuggestion = true; });
    }

    try {
      final weatherData = await WeatherService.getWeather('Da Nang');
      if (mounted) setState(() => _currentWeather = weatherData);

      final items = await DatabaseHelper.instance.getAllItems().then((data) => data.map((item) => ClothingItem.fromMap(item)).toList());
      if (items.isEmpty) throw Exception('Tủ đồ trống.');

      final suggestion = await SuggestionService.getOutfitSuggestion(weather: weatherData, items: items);
      
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_suggestion_text', suggestion);
      await prefs.setString('last_suggestion_timestamp', now.toIso8601String());
      
      if(mounted) {
        setState(() {
          _aiSuggestion = suggestion;
          _suggestionTimestamp = now;
        });
      }
    } catch (e, s) {
      logger.w('Không thể lấy gợi ý', error: e, stackTrace: s);
      if (mounted) {
        setState(() {
          _aiSuggestion = e.toString().contains('Tủ đồ trống')
              ? 'Hãy thêm đồ vào tủ để nhận gợi ý.'
              : 'Không thể nhận gợi ý lúc này.';
          _suggestionTimestamp = null;
        });
      }
    } finally {
      if(mounted) setState(() => _isLoadingSuggestion = false);
    }
  }

  Future<void> _dismissPromoCard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('promoCardDismissed', true);
    setState(() => _isPromoCardDismissed = true);
  }

  Future<List<ClothingItem>> _loadRecentItems() async {
    final dataList = await DatabaseHelper.instance.getRecentItems(5);
    return dataList.map((itemMap) => ClothingItem.fromMap(itemMap)).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: _buildHeader(),
        toolbarHeight: 80,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSuggestion,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isPromoCardDismissed) _buildPromoCard(),
              const SizedBox(height: 32),
              _buildAiStylistSection(),
              const SizedBox(height: 32),
              _buildRecentlyAddedSection(),
              const SizedBox(height: 32),
              _buildTodaysSuggestionCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
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
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, size: 28)),
      ],
    );
  }

  Widget _buildPromoCard() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 40, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepPurple.shade200, Colors.purple.shade300], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
        Positioned(top: 4, right: 4, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 20), onPressed: _dismissPromoCard)),
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
            Expanded(child: Container(height: 100, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.shade400, borderRadius: BorderRadius.circular(16)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(Icons.auto_awesome, color: Colors.white), Text('Bắt đầu phối đồ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]))),
            const SizedBox(width: 16),
            Expanded(child: Container(height: 100, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(Icons.history, color: Colors.black), Text('Lịch sử', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))]))),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentlyAddedSection() {
    return Column(
      children: [
        SectionHeader(title: 'Đã thêm gần đây', onSeeAll: () {}),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: FutureBuilder<List<ClothingItem>>(
            future: _loadRecentItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildAddFirstItemButton();
              final items = snapshot.data!;
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
  
  Widget _buildTodaysSuggestionCard() {
    return Column(
      children: [
        SectionHeader(
          title: 'Gợi ý hôm nay',
          actionIcon: Icons.refresh,
          onActionPressed: _fetchSuggestion,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
          child: _isLoadingSuggestion
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentWeather != null) ...[
                      Text(
                        _currentWeather!['name'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(_getWeatherIcon(_currentWeather!['weather'][0]['icon']), color: Colors.orange.shade700, size: 32),
                          const SizedBox(width: 8),
                          Text('${_currentWeather!['main']['temp'].toStringAsFixed(0)}°C', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 24, thickness: 0.5),
                    ],
                    Text(
                      _aiSuggestion ?? 'Chưa có gợi ý nào. Hãy nhấn nút làm mới!',
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    if (_suggestionTimestamp != null && _aiSuggestion != null && !_aiSuggestion!.contains('lỗi') && !_aiSuggestion!.contains('gợi ý')) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Cập nhật lúc: ${DateFormat('HH:mm, dd/MM/yyyy').format(_suggestionTimestamp!)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
        )
      ],
    );
  }

  Widget _buildAddFirstItemButton() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => const AddItemScreen()),
        ).then((_) => setState(() {}));
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
}