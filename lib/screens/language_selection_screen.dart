// lib/screens/language_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/locale_provider.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PageScaffold(
      appBar: AppBar(
        title: Text(l10n.settings_language_tile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _LanguageTile(
            nativeName: 'English',
            englishName: 'English',
            locale: Locale('en'),
          ),
          SizedBox(height: 8),
          _LanguageTile(
            nativeName: 'Tiếng Việt',
            englishName: 'Vietnamese',
            locale: Locale('vi'),
          ),
        ],
      ),
    );
  }
}

// Widget helper cho mỗi lựa chọn ngôn ngữ
class _LanguageTile extends ConsumerWidget {
  final String nativeName;
  final String englishName;
  final Locale locale;

  const _LanguageTile({
    required this.nativeName,
    required this.englishName,
    required this.locale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isSelected = currentLocale.languageCode == locale.languageCode;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      // Thay đổi màu nền dựa trên việc có được chọn hay không
      color: isSelected ? theme.colorScheme.primary.withValues(alpha:0.1) : theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Thêm đường viền để làm nổi bật lựa chọn
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () {
          ref.read(localeProvider.notifier).setLocale(locale.languageCode);
          // Tùy chọn: Tự động quay về sau khi chọn
          // Navigator.of(context).pop(); 
        },
        title: Text(
          nativeName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          englishName,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        // Hiển thị icon dấu tick nếu được chọn
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : null,
      ),
    );
  }
}