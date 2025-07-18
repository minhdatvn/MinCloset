// lib/helpers/pro_image_editor_i18n_helper.dart
import 'package:mincloset/l10n/app_localizations.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Trả về một đối tượng I18n đã được dịch dựa trên AppLocalizations.
I18n getProImageEditorI18n(AppLocalizations l10n) {
  return I18n(
    // === Các chuỗi chung ===
    done: l10n.proImageEditor_common_done,
    cancel: l10n.proImageEditor_common_cancel,
    undo: l10n.proImageEditor_common_undo,
    redo: l10n.proImageEditor_common_redo,
    remove: l10n.proImageEditor_common_remove,

    // === Các trình chỉnh sửa cụ thể ===
    paintEditor: I18nPaintEditor(
      bottomNavigationBarText: l10n.proImageEditor_paint_title,
      done: l10n.proImageEditor_common_done,
      back: l10n.proImageEditor_common_back,
      undo: l10n.proImageEditor_common_undo,
      redo: l10n.proImageEditor_common_redo,
      smallScreenMoreTooltip: l10n.proImageEditor_common_more,
    ),
    textEditor: I18nTextEditor(
      bottomNavigationBarText: l10n.proImageEditor_text_title,
      inputHintText: l10n.proImageEditor_text_hint,
      done: l10n.proImageEditor_common_done,
      back: l10n.proImageEditor_common_back,
      smallScreenMoreTooltip: l10n.proImageEditor_common_more,
    ),
    emojiEditor: I18nEmojiEditor(
      bottomNavigationBarText: l10n.proImageEditor_emoji_title,
    ),

    cropRotateEditor: I18nCropRotateEditor(
      bottomNavigationBarText: l10n.proImageEditor_crop_title,
      done: l10n.proImageEditor_common_done,
      back: l10n.proImageEditor_common_back,
      cancel: l10n.proImageEditor_common_cancel,
      undo: l10n.proImageEditor_common_undo,
      redo: l10n.proImageEditor_common_redo,
      rotate: l10n.proImageEditor_crop_rotate,
      flip: l10n.proImageEditor_crop_flip,
      ratio: l10n.proImageEditor_crop_ratio,
      reset: l10n.proImageEditor_crop_reset,
      smallScreenMoreTooltip: l10n.proImageEditor_common_more,
    ),
    filterEditor: I18nFilterEditor(
      bottomNavigationBarText: l10n.proImageEditor_filter_title,
      done: l10n.proImageEditor_common_done,
      back: l10n.proImageEditor_common_back,
      filters: I18nFilters(
        none: l10n.proImageEditor_filter_noFilter,
      ),
    ),
    tuneEditor: I18nTuneEditor(
      bottomNavigationBarText: l10n.proImageEditor_tune_title,
      done: l10n.proImageEditor_common_done,
      back: l10n.proImageEditor_common_back,
      undo: l10n.proImageEditor_common_undo,
      redo: l10n.proImageEditor_common_redo,
      brightness: l10n.proImageEditor_tune_brightness,
      contrast: l10n.proImageEditor_tune_contrast,
      saturation: l10n.proImageEditor_tune_saturation,
      exposure: l10n.proImageEditor_tune_exposure,
      hue: l10n.proImageEditor_tune_hue,
      temperature: l10n.proImageEditor_tune_temperature,
      sharpness: l10n.proImageEditor_tune_sharpness,
      fade: l10n.proImageEditor_tune_fade,
      luminance: l10n.proImageEditor_tune_luminance,
    ),
    blurEditor: I18nBlurEditor(
      bottomNavigationBarText: l10n.proImageEditor_blur_title,
      done: l10n.proImageEditor_common_done,
      back: l10n.proImageEditor_common_back,
    ),
    stickerEditor: I18nStickerEditor(
      bottomNavigationBarText: l10n.proImageEditor_sticker_title,
    ),
    layerInteraction: I18nLayerInteraction(
      remove: l10n.proImageEditor_common_remove,
      edit: l10n.proImageEditor_common_edit,
      rotateScale: l10n.proImageEditor_common_rotateScale,
    ),
  );
}