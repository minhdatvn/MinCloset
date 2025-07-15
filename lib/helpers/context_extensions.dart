// lib/helpers/context_extensions.dart
import 'package:flutter/widgets.dart';
import 'package:mincloset/l10n/app_localizations.dart';

extension BuildContextHelper on BuildContext {
  /// Cung cấp một phím tắt để truy cập AppLocalizations.
  /// Thay vì phải viết: AppLocalizations.of(this)!,
  /// giờ đây bạn chỉ cần viết: context.l10n
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}