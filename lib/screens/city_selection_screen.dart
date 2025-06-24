// lib/screens/city_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/city_selection_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/states/city_selection_state.dart';
import 'package:mincloset/states/profile_page_state.dart';

class CitySelectionScreen extends ConsumerStatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  ConsumerState<CitySelectionScreen> createState() =>
      _CitySelectionScreenState();
}

class _CitySelectionScreenState extends ConsumerState<CitySelectionScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(citySelectionProvider);
    final notifier = ref.read(citySelectionProvider.notifier);

    ref.listen<CitySelectionState>(citySelectionProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ref.read(notificationServiceProvider).showBanner(message: next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select location'),
        actions: [
          if (!state.isLoading)
            TextButton(
              onPressed: () async {
                // <<< SỬA LỖI TRIỆT ĐỂ: Lấy Navigator ra trước khi có await >>>
                final navigator = Navigator.of(context);
                final success = await notifier.saveSelection();

                if (success && mounted) {
                  navigator.pop();
                }
              },
              child: const Text('Save'),
            )
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                RadioListTile<CityMode>(
                  title: const Text('Auto-detect'),
                  value: CityMode.auto,
                  groupValue: state.selectedMode,
                  onChanged: (value) => notifier.setMode(value!),
                ),
                RadioListTile<CityMode>(
                  title: const Text('Manually'),
                  subtitle: Text(state.selectedSuggestion?.displayName ??
                      state.currentManualCityName),
                  value: CityMode.manual,
                  groupValue: state.selectedMode,
                  onChanged: (value) => notifier.setMode(value!),
                ),
                if (state.selectedMode == CityMode.manual) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _textController,
                      onChanged: notifier.search,
                      decoration: InputDecoration(
                        hintText: 'Search city/location…',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: state.isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = state.suggestions[index];
                        return ListTile(
                          title: Text(suggestion.displayName),
                          onTap: () {
                            notifier.selectSuggestion(suggestion);
                            _textController.clear();
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}