// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <<< THÊM IMPORT
import 'package:mincloset/providers/ui_providers.dart'; // <<< THÊM IMPORT
import 'package:mincloset/screens/pages/closets_page.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/screens/pages/outfits_hub_page.dart';
import 'package:mincloset/screens/pages/profile_page.dart';
import 'package:mincloset/widgets/global_add_button.dart';

// <<< CHUYỂN THÀNH CONSUMERSTATEFULWIDGET
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  // Bỏ biến _selectedIndex cục bộ

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ClosetsPage(),
    OutfitsHubPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    // Thay vì setState, chúng ta cập nhật provider
    ref.read(mainScreenIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    // "Theo dõi" provider để lấy ra index hiện tại
    final selectedIndex = ref.watch(mainScreenIndexProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        Scaffold(
          // Sử dụng selectedIndex từ provider
          body: _widgetOptions.elementAt(selectedIndex),
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(icon: Icons.home, label: 'Trang chủ', index: 0, selectedIndex: selectedIndex),
                _buildNavItem(icon: Icons.checkroom, label: 'Tủ đồ', index: 1, selectedIndex: selectedIndex),
                const SizedBox(width: 40), // Khoảng trống cho nút FAB
                _buildNavItem(icon: Icons.style, label: 'Trang phục', index: 2, selectedIndex: selectedIndex),
                _buildNavItem(icon: Icons.person_outline, label: 'Cá nhân', index: 3, selectedIndex: selectedIndex),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20.0,
          left: 0,
          right: 0,
          child: const Center(
            child: GlobalAddButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index, required int selectedIndex}) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? Colors.deepPurple : Colors.grey;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}