// file: lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/screens/pages/closets_page.dart';
import 'package:mincloset/screens/pages/outfits_hub_page.dart';
import 'package:mincloset/screens/pages/profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // <<< THAY ĐỔI TRONG DANH SÁCH WIDGET
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const ClosetsPage(),
    const OutfitsHubPage(), // Thay thế OutfitBuilderPage bằng OutfitsHubPage
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {_selectedIndex = index;});
  }
  
  void _navigateToAddItemScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const AddItemScreen()),
    ).then((_) {
      // Sau khi thêm đồ xong và quay lại, refresh lại trang hiện tại
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold giờ đã được chuyển vào từng trang con.
    // File này chỉ trả về widget tương ứng với tab được chọn.
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),

      floatingActionButton: FloatingActionButton(
        heroTag: 'main_screen_fab',
        onPressed: _navigateToAddItemScreen, // Thêm hành động thật cho nút '+'
        shape: const CircleBorder(),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(icon: Icons.home, label: 'Trang chủ', index: 0),
            _buildNavItem(icon: Icons.checkroom, label: 'Tủ đồ', index: 1),
            const SizedBox(width: 40),
            _buildNavItem(icon: Icons.style, label: 'Phối đồ', index: 2),
            _buildNavItem(icon: Icons.person_outline, label: 'Cá nhân', index: 3),
          ],
        ),
      ),
    );
  }
  
  // Hàm này giữ nguyên
  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? Colors.black : Colors.grey;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}