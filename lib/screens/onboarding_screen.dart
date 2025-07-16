// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/flow_providers.dart';
import 'package:mincloset/providers/locale_provider.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0;

  // Function to complete the onboarding process
  Future<void> _completeOnboarding() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Save the user's name
      await ref
          .read(profileProvider.notifier)
          .updateProfileInfo({'name': _nameController.text.trim()});

      // Mark onboarding as completed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_onboarding', true);

      ref.read(onboardingCompletedProvider.notifier).state = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // We will pass the index to _buildPage to know which page it is
    final pages = [
      _buildPage(
        context,
        index: 0, // Page 1
        imagePath: 'assets/images/onboarding/onboarding_p1.webp',
        title: l10n.onboarding_page1_title,
        subtitle: l10n.onboarding_page1_subtitle,
        description: l10n.onboarding_page1_description,
      ),
      _buildPage(
        context,
        index: 1, // Page 2
        imagePath: 'assets/images/onboarding/onboarding_p2.webp',
        title: l10n.onboarding_page2_title,
        description: '', // Mô tả không cần nữa vì đã có isFeatureList
        isFeatureList: true,
      ),
      _buildNamePage(context),
    ];

    return PageScaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return pages[index];
              },
            ),
          ),
          _buildBottomControls(context, pages.length),
        ],
      ),
    );
  }

  // Widget to build the pages
  Widget _buildPage(BuildContext context,
      {required int index,
      required String imagePath,
      required String title,
      String? subtitle,
      required String description,
      bool isFeatureList = false}) {
    final theme = Theme.of(context);

    // Apply the new style for page 0 and 1
    if (index == 0 || index == 1) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Full-screen background image
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: Text(
                      'Image not found.\nPlease check path in pubspec.yaml\nPath: $imagePath',
                      textAlign: TextAlign.center),
                ),
              );
            },
          ),
          // Layer 2: Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha:1),
                  Colors.white.withValues(alpha:0.0),
                ],
                stops: const [0.0, 0.4, 1.0],
                begin: Alignment.bottomCenter,
                end: const Alignment(0.0, -1.0 / 3.0),
              ),
            ),
          ),
          // Layer 3: Content
          Positioned(
            // Nếu là trang 1 (index 0), giữ nguyên khoảng cách 120.
            // Nếu là trang 2 (index 1), giảm khoảng cách xuống còn 80 để chữ đi xuống thấp hơn.
            bottom: index == 0 ? 120 : 40, 
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(subtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall),
                ],
                const SizedBox(height: 16),
                // Show feature list on the second page
                if (isFeatureList)
                  _buildFeatureList(context)
                else
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
              ],
            ),
          )
        ],
      );
    }

    // Default layout for any other pages (not used in this 3-page setup but good for fallback)
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath,
              height: 200,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 150)),
          const SizedBox(height: 40),
          Text(title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall),
          ],
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  // Widget for the final name input page
  Widget _buildNamePage(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/mascot.webp', height: 150),
          const SizedBox(height: 24),
          Text(context.l10n.onboarding_page3_title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(context.l10n.onboarding_page3_subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
              decoration: InputDecoration(
                hintText: context.l10n.onboarding_page3_nameHint,
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.onboarding_page3_nameValidator;
                }
                return null;
              },
            ),
          )
        ],
      ),
    );
  }

  // Page indicator dots and buttons
  Widget _buildBottomControls(BuildContext context, int pageCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Cụm chỉ báo trang (giữ nguyên)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pageCount,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 2. Thêm widget chọn ngôn ngữ vào đây
          _buildLanguageSelector(context),

          // 3. Nút bấm Next/Done (giữ nguyên)
          ElevatedButton(
            onPressed: () {
              if (_currentPage < pageCount - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              } else {
                _completeOnboarding();
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
            ),
            child: _currentPage < pageCount - 1
                ? const Icon(Icons.arrow_forward_ios)
                : const Icon(Icons.check),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _featureItem(context, Icons.camera_alt_outlined, l10n.onboarding_page2_feature1_title, l10n.onboarding_page2_feature1_desc),
        const SizedBox(height: 16),
        _featureItem(context, Icons.lightbulb_outline, l10n.onboarding_page2_feature2_title, l10n.onboarding_page2_feature2_desc),
        const SizedBox(height: 16),
        _featureItem(context, Icons.brush_outlined, l10n.onboarding_page2_feature3_title, l10n.onboarding_page2_feature3_desc),
        const SizedBox(height: 16),
        _featureItem(context, Icons.calendar_today_outlined, l10n.onboarding_page2_feature4_title, l10n.onboarding_page2_feature4_desc),
      ],
    );
  }

  Widget _featureItem(
      BuildContext context, IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final currentLocale = ref.watch(localeProvider);

        return PopupMenuButton<Locale>(
          onSelected: (Locale newLocale) {
            ref.read(localeProvider.notifier).setLocale(newLocale.languageCode);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentLocale.languageCode == 'en' ? 'English' : 'Tiếng Việt',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 20.0),
              ],
            ),
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
            const PopupMenuItem<Locale>(
              value: Locale('en'),
              child: Text('English'),
            ),
            const PopupMenuItem<Locale>(
              value: Locale('vi'),
              child: Text('Tiếng Việt'),
            ),
          ],
        );
      },
    );
  }
}