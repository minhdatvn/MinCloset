// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:mincloset/screens/pages/closets_page.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/screens/pages/outfits_hub_page.dart';
import 'package:mincloset/screens/pages/profile_page.dart';
import 'package:mincloset/widgets/global_add_button.dart'; // <<< Import nút bấm độc lập

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ClosetsPage(),
    OutfitsHubPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // <<< SỬ DỤNG STACK ĐỂ ĐẶT NÚT BẤM LÊN TRÊN GIAO DIỆN
    return Stack(
      // Dùng StackFit.expand để các lớp con lấp đầy màn hình
      fit: StackFit.expand,
      children: [
        // LỚP DƯỚI CÙNG: Scaffold chứa các trang và thanh điều hướng
        Scaffold(
          body: _widgetOptions.elementAt(_selectedIndex),
          // Dùng BottomAppBar để có thể tạo "khuyết" cho nút bấm
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(icon: Icons.home, label: 'Trang chủ', index: 0),
                _buildNavItem(icon: Icons.checkroom, label: 'Tủ đồ', index: 1),
                // Khoảng trống ở giữa cho nút FAB
                const SizedBox(width: 40), 
                _buildNavItem(icon: Icons.style, label: 'Phối đồ', index: 2),
                _buildNavItem(icon: Icons.person_outline, label: 'Cá nhân', index: 3),
              ],
            ),
          ),
        ),
        // LỚP TRÊN CÙNG: Nút bấm độc lập
        // Dùng Positioned để căn chỉnh vị trí của nút
        Positioned(
          bottom: 25.0, // Khoảng cách từ dưới lên
          // Căn nút vào giữa theo chiều ngang
          left: 0,
          right: 0,
          child: const Center(
            child: GlobalAddButton(),
          ),
        ),
      ],
    );
  }

  // Hàm helper để tạo một item trên thanh điều hướng
  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? Colors.deepPurple : Colors.grey;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}