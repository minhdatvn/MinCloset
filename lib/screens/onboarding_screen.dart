// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
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
      final navigator = Navigator.of(context);
      // Save the user's name
      await ref
          .read(profileProvider.notifier)
          .updateProfileInfo({'name': _nameController.text.trim()});

      // Mark onboarding as completed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_onboarding', true);

      // Navigate to the main screen
      if (mounted) {
        navigator.pushReplacementNamed(AppRoutes.main);
      }
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
    final pages = [
      _buildPage(
        context,
        imagePath: 'assets/images/badges/badge_beginner.webp', // Placeholder
        title: "A closet full of clothes...",
        subtitle: "...but nothing to wear?",
        description:
            "Do you often spend time wondering what to wear? Do you forget what amazing items you already own?",
      ),
      _buildPage(
        context,
        imagePath: 'assets/images/badges/badge_beginner.webp', // Placeholder
        title: "MinCloset, Your Smart Closet Assistant",
        description:
            "We help you digitize your closet, get AI-powered outfit suggestions, creatively build your own outfits, and track your style journey.",
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

  // Widget to build the first two pages
  Widget _buildPage(BuildContext context,
      {required String imagePath,
      required String title,
      String? subtitle,
      required String description,
      bool isFeatureList = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 200),
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
          Text("Let's get to know each other!",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text("Tell MinCloset your name so we can get more personal.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
              decoration: const InputDecoration(
                hintText: "Enter your name...",
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please tell me your name';
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dots indicator
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

          // Button
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _featureItem(context, Icons.camera_alt_outlined, "Digitize Your Closet",
            "Snap a photo and let AI automatically categorize your clothes."),
        const SizedBox(height: 16),
        _featureItem(context, Icons.lightbulb_outline, "AI Outfit Suggestions",
            "Get personalized outfit ideas based on your items and the weather."),
        const SizedBox(height: 16),
        _featureItem(
            context,
            Icons.brush_outlined,
            "Creative Outfit Studio",
            "Freely mix and match items to create unique looks."),
        const SizedBox(height: 16),
        _featureItem(context, Icons.calendar_today_outlined,
            "Track Your Style Journey", "Log what you wear and discover your habits."),
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
}