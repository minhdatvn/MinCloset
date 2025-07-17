// lib/screens/city_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/models/city_suggestion.dart';
import 'package:mincloset/notifiers/city_selection_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/states/city_selection_state.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/widgets/page_scaffold.dart';

class CitySelectionScreen extends ConsumerStatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  ConsumerState<CitySelectionScreen> createState() =>
      _CitySelectionScreenState();
}

class _CitySelectionScreenState extends ConsumerState<CitySelectionScreen> {
  final _textController = TextEditingController();
  // Sử dụng ExpansibleController
  final ExpansibleController _expansibleController = ExpansibleController();

  @override
  void dispose() {
    _textController.dispose();
    _expansibleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(citySelectionProvider);
    final notifier = ref.read(citySelectionProvider.notifier);

    ref.listen<CitySelectionState>(citySelectionProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ref.read(notificationServiceProvider).showBanner(message: next.errorMessage!);
      }
      
      if (next.selectedMode == CityMode.auto) {
        // SỬA LỖI: Dùng phương thức .collapse()
        _expansibleController.collapse();
      }
    });

    return PageScaffold(
      appBar: AppBar(
        title: Text(l10n.citySelection_title),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _LocationTile(
                  title: l10n.citySelection_autoDetect,
                  subtitle: l10n.citySelection_autoDetect_subtitle,
                  isSelected: state.selectedMode == CityMode.auto,
                  onTap: notifier.selectAutoDetect,
                ),
                const SizedBox(height: 8),

                _LocationTile(
                  expansibleController: _expansibleController,
                  title: l10n.citySelection_manual,
                  subtitle: state.selectedSuggestion?.displayName ?? state.currentManualCityName,
                  isSelected: state.selectedMode == CityMode.manual,
                  onExpansionChanged: (isExpanded) {
                      if (isExpanded) {
                          notifier.setManualMode();
                      }
                  },
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: TextField(
                        controller: _textController,
                        onChanged: notifier.search,
                        decoration: InputDecoration(
                          hintText: l10n.citySelection_searchHint,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: state.isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : null,
                        ),
                      ),
                    ),
                    if (state.suggestions.isNotEmpty)
                      SizedBox(
                        height: 200, 
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.suggestions.length,
                          itemBuilder: (context, index) {
                            final CitySuggestion suggestion = state.suggestions[index];
                            return ListTile(
                              title: Text(suggestion.displayName),
                              onTap: () {
                                // Gọi hàm mới để chọn và lưu
                                notifier.selectManualCity(suggestion);

                                // Các hành động dọn dẹp giao diện giữ nguyên
                                _textController.clear();
                                _expansibleController.collapse();
                                FocusScope.of(context).unfocus();
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

// Widget helper cho các lựa chọn
class _LocationTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback? onTap;
  // Sửa kiểu của controller
  final ExpansibleController? expansibleController;
  final List<Widget> children;
  final Function(bool)? onExpansionChanged;

  const _LocationTile({
    required this.title,
    this.subtitle,
    required this.isSelected,
    this.onTap,
    this.expansibleController,
    this.children = const [],
    this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
        width: isSelected ? 1.5 : 1.0,
      ),
    );

    // Nếu là ExpansionTile
    if (expansibleController != null) {
      return Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: cardShape,
        clipBehavior: Clip.antiAlias,
        color: isSelected ? theme.colorScheme.primary.withValues(alpha:0.05) : theme.cardTheme.color,
        child: ExpansionTile(
          controller: expansibleController,
          onExpansionChanged: onExpansionChanged,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          trailing: isSelected
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : null,
          children: children,
        ),
      );
    }
    
    // Nếu là ListTile thông thường
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: cardShape,
      clipBehavior: Clip.antiAlias,
      color: isSelected ? theme.colorScheme.primary.withValues(alpha:0.1) : theme.cardTheme.color,
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : null,
      ),
    );
  }
}