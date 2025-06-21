// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/home_page_notifier.dart'; // <<< THÊM IMPORT
import 'package:mincloset/notifiers/profile_page_notifier.dart'; // <<< THÊM IMPORT
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/screens/pages/closets_page.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/screens/pages/outfits_hub_page.dart';
import 'package:mincloset/screens/pages/profile_page.dart';
import 'package:mincloset/widgets/global_add_button.dart';

// <<< THAY ĐỔI 2: Chuyển thành ConsumerStatefulWidget >>>
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  // <<< THAY ĐỔI 3: Thêm initState để tải dữ liệu ban đầu >>>
  @override
  void initState() {
    super.initState();
    // Dùng addPostFrameCallback để đảm bảo các provider đã sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadInitialData();
      ref.read(homeProvider.notifier).getNewSuggestion();
    });
  }

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
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 18),
        child: const GlobalAddButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        height: 70,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              context: context,
              icon: Icons.home_filled,
              label: 'Home',
              index: 0,
              selectedIndex: selectedIndex,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.checkroom_outlined,
              label: 'Closets',
              index: 1,
              selectedIndex: selectedIndex,
            ),
            const SizedBox(width: 48),
            _buildNavItem(
              context: context,
              icon: Icons.style_outlined,
              label: 'Outfits',
              index: 2,
              selectedIndex: selectedIndex,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.person_outline,
              label: 'Profile',
              index: 3,
              selectedIndex: selectedIndex,
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
    required int selectedIndex,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedIndex == index;
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withAlpha(130);

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
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