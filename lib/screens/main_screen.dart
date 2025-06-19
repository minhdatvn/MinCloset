// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/screens/pages/closets_page.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/screens/pages/outfits_hub_page.dart';
import 'package:mincloset/screens/pages/profile_page.dart';
import 'package:mincloset/widgets/global_add_button.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ClosetsPage(),
    OutfitsHubPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    ref.read(mainScreenIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(mainScreenIndexProvider);

    return Scaffold(
      body: _widgetOptions.elementAt(selectedIndex),
      floatingActionButton: const GlobalAddButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        // <<< SỬA LỖI: Tăng chiều cao lên một chút nữa >>>
        height: 70, 
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Thêm padding cho thanh bar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              context: context,
              icon: Icons.home_filled, 
              label: 'Trang chủ', 
              index: 0, 
              selectedIndex: selectedIndex
            ),
            _buildNavItem(
              context: context,
              icon: Icons.checkroom_outlined, 
              label: 'Tủ đồ', 
              index: 1, 
              selectedIndex: selectedIndex
            ),
            const SizedBox(width: 48), // Tăng khoảng trống cho nút FAB
            _buildNavItem(
              context: context,
              icon: Icons.style_outlined, 
              label: 'Trang phục', 
              index: 2, 
              selectedIndex: selectedIndex
            ),
            _buildNavItem(
              context: context,
              icon: Icons.person_outline, 
              label: 'Cá nhân', 
              index: 3, 
              selectedIndex: selectedIndex
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon, 
    required String label, 
    required int index, 
    required int selectedIndex
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedIndex == index;
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(130);
    
    // Bọc trong Expanded để các mục chiếm không gian bằng nhau
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // <<< SỬA LỖI: Giảm nhẹ kích thước icon và khoảng cách >>>
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11, // Giảm nhẹ font size
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}