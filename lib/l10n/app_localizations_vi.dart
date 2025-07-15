// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get language_english => 'English';

  @override
  String get language_vietnamese => 'Tiếng Việt';

  @override
  String banner_deleteSuccess(Object itemName) {
    return 'Đã xoá \"$itemName\".';
  }

  @override
  String get banner_deleteFailed => 'Xoá thất bại. Vui lòng thử lại.';

  @override
  String get common_cancel => 'Huỷ';

  @override
  String get common_today => 'Hôm nay';

  @override
  String get profile_title => 'Hồ sơ';

  @override
  String get profile_settings_tooltip => 'Cài đặt';

  @override
  String get profile_editProfile_label => 'Chỉnh sửa hồ sơ';

  @override
  String get profile_unnamed_label => 'Chưa đặt tên';

  @override
  String get profile_achievements_label => 'Thành tích';

  @override
  String get profile_closetsOverview_sectionHeader => 'Tổng quan tủ đồ';

  @override
  String get profile_insights_button => 'Thống kê chi tiết';

  @override
  String get profile_statistics_sectionHeader => 'Thống kê';

  @override
  String get profile_noData_message => 'Không có dữ liệu thống kê';

  @override
  String get profile_statPage_category => 'Danh mục';

  @override
  String get profile_statPage_color => 'Màu sắc';

  @override
  String get profile_statPage_season => 'Mùa';

  @override
  String get profile_statPage_occasion => 'Dịp';

  @override
  String get profile_statPage_material => 'Chất liệu';

  @override
  String get profile_statPage_pattern => 'Hoạ tiết';

  @override
  String get profile_takePhoto_label => 'Chụp ảnh';

  @override
  String get profile_fromAlbum_label => 'Từ Album';

  @override
  String get settings_title => 'Cài đặt';

  @override
  String get settings_general_sectionHeader => 'Cài đặt chung';

  @override
  String get settings_localization_tile => 'Khu vực';

  @override
  String get settings_location_tile => 'Vị trí';

  @override
  String get settings_autoDetect_label => 'Tự động phát hiện';

  @override
  String get settings_language_tile => 'Ngôn ngữ';

  @override
  String get settings_currency_tile => 'Tiền tệ';

  @override
  String get settings_decimalFormat_tile => 'Định dạng số';

  @override
  String get settings_units_tile => 'Đơn vị';

  @override
  String get settings_height_label => 'Chiều cao';

  @override
  String get settings_weight_label => 'Cân nặng';

  @override
  String get settings_temp_label => 'Nhiệt độ';

  @override
  String get settings_notifications_tile => 'Thông báo';

  @override
  String get settings_enableAllNotifications_label => 'Bật tất cả thông báo';

  @override
  String get settings_morningReminder_label => 'Nhắc nhở buổi sáng (7:00)';

  @override
  String get settings_morningReminder_subtitle =>
      'Nhận gợi ý cho kế hoạch trang phục hàng ngày.';

  @override
  String get settings_eveningReminder_label => 'Nhắc nhở buổi tối (20:00)';

  @override
  String get settings_eveningReminder_subtitle =>
      'Nhắc nhở cập nhật nhật ký thời trang của bạn.';

  @override
  String get settings_display_tile => 'Hiển thị';

  @override
  String get settings_showWeatherBg_label => 'Hiện ảnh nền thời tiết';

  @override
  String get settings_showWeatherBg_subtitle =>
      'Hiển thị hình ảnh dựa trên thời tiết';

  @override
  String get settings_showMascot_label => 'Hiển thị Mascot';

  @override
  String get settings_showMascot_subtitle => 'Hiển thị trợ lý trên màn hình';

  @override
  String get settings_aboutSupport_sectionHeader => 'Giới thiệu & Hỗ trợ';

  @override
  String get settings_aboutLegal_tile => 'Giới thiệu & Pháp lý';

  @override
  String get settings_sendFeedback_tile => 'Gửi phản hồi';

  @override
  String get settings_sendFeedback_subtitle =>
      'Giúp chúng tôi cải thiện MinCloset';

  @override
  String get settings_rateApp_tile => 'Đánh giá trên App Store';

  @override
  String get editProfile_title => 'Chỉnh sửa hồ sơ';

  @override
  String get editProfile_saveButton => 'Lưu';

  @override
  String get editProfile_basicInfo_sectionHeader => 'Thông tin cơ bản';

  @override
  String get editProfile_fullName_label => 'Họ và tên';

  @override
  String get editProfile_gender_label => 'Giới tính';

  @override
  String get editProfile_birthday_label => 'Ngày sinh';

  @override
  String get editProfile_notSelected_label => 'Chưa chọn';

  @override
  String get editProfile_height_cm_label => 'Chiều cao (cm)';

  @override
  String get editProfile_height_ft_in_label => 'Chiều cao';

  @override
  String get editProfile_weight_label => 'Cân nặng';

  @override
  String get editProfile_interests_sectionHeader => 'Sở thích & Phong cách';

  @override
  String get editProfile_personalStyle_label => 'Phong cách cá nhân';

  @override
  String get editProfile_favoriteColors_label => 'Màu sắc yêu thích';

  @override
  String get gender_male => 'Nam';

  @override
  String get gender_female => 'Nữ';

  @override
  String get gender_other => 'Khác';

  @override
  String get quests_title => 'Thành tích';

  @override
  String get quests_yourBadges_sectionHeader => 'Huy hiệu của bạn';

  @override
  String get quests_inProgress_sectionHeader => 'Đang thực hiện';

  @override
  String get quests_noActiveQuests_message => 'Không có nhiệm vụ nào.';

  @override
  String get quest_event_topAdded => 'Số lượng áo đã thêm';

  @override
  String get quest_event_bottomAdded => 'Số lượng quần/váy đã thêm';

  @override
  String get quest_event_suggestionReceived => 'Gợi ý từ AI';

  @override
  String get quest_event_outfitCreated => 'Đã tạo Trang phục';

  @override
  String get quest_event_closetCreated => 'Đã tạo Tủ đồ mới';

  @override
  String get quest_event_logAdded => 'Đã ghi Nhật ký';

  @override
  String get quest_firstSteps_title => 'Bước chân đầu tiên vào Tủ đồ số';

  @override
  String get quest_firstSteps_description =>
      'Thêm 3 áo và 3 quần/váy đầu tiên để bắt đầu nhận gợi ý trang phục cá nhân hóa.';

  @override
  String get quest_firstSuggestion_title => 'Gợi ý đầu tiên từ AI';

  @override
  String get quest_firstSuggestion_description =>
      'Hãy xem AI có gì dành cho bạn. Nhận ngay gợi ý trang phục đầu tiên!';

  @override
  String get quest_firstOutfit_title => 'Sáng tạo đầu tay';

  @override
  String get quest_firstOutfit_description =>
      'Sử dụng Trình tạo Trang phục để tạo và lưu bộ đồ tùy chỉnh đầu tiên của bạn.';

  @override
  String get quest_organizeCloset_title => 'Sắp xếp gọn gàng';

  @override
  String get quest_organizeCloset_description =>
      'Tạo một tủ đồ mới để sắp xếp quần áo tốt hơn (ví dụ: cho công việc, cho thể thao).';

  @override
  String get quest_firstLog_title => 'Theo dõi Hành trình Phong cách';

  @override
  String get quest_firstLog_description =>
      'Ghi lại một món đồ hoặc một bộ trang phục vào Nhật ký để theo dõi những gì bạn mặc.';

  @override
  String get outfitsHub_title => 'Trang phục của bạn';

  @override
  String outfitsHub_lastWorn(Object date) {
    return 'Mặc lần cuối: $date';
  }

  @override
  String get outfitsHub_lastWorn_never => 'Chưa mặc';

  @override
  String get outfitsHub_rename_label => 'Đổi tên';

  @override
  String get outfitsHub_share_label => 'Chia sẻ';

  @override
  String get outfitsHub_viewDetails_label => 'Xem chi tiết';

  @override
  String get outfitsHub_delete_label => 'Xoá';

  @override
  String get outfitsHub_rename_dialogTitle => 'Đổi tên trang phục';

  @override
  String get outfitsHub_newName_label => 'Tên mới';

  @override
  String get outfitsHub_cancel_button => 'Huỷ';

  @override
  String get outfitsHub_save_button => 'Lưu';

  @override
  String get outfitsHub_delete_dialogTitle => 'Xác nhận xoá';

  @override
  String outfitsHub_delete_dialogContent(Object outfitName) {
    return 'Xoá vĩnh viễn trang phục \"$outfitName\"?';
  }

  @override
  String get outfitsHub_create_cardLabel => 'Tạo trang phục';

  @override
  String get outfitsHub_create_hintTitle => 'Xưởng phối đồ';

  @override
  String get outfitsHub_create_hintDescription =>
      'Nhấn vào đây để phối các vật phẩm và tạo ra những bộ đồ độc đáo của riêng bạn.';

  @override
  String get outfitBuilder_title => 'Xưởng phối đồ';

  @override
  String get outfitBuilder_changeBg_button => 'Đổi ảnh nền';

  @override
  String get outfitBuilder_undo_tooltip => 'Hoàn tác';

  @override
  String get outfitBuilder_redo_tooltip => 'Làm lại';

  @override
  String get outfitBuilder_save_dialogTitle => 'Lưu trang phục';

  @override
  String get outfitBuilder_save_nameHint => 'Ví dụ: Cà phê cuối tuần';

  @override
  String get outfitBuilder_save_nameValidator => 'Vui lòng nhập tên trang phục';

  @override
  String get outfitBuilder_save_isFixedLabel => 'Bộ đồ cố định';

  @override
  String get outfitBuilder_save_isFixedSubtitle =>
      'Các món trong bộ này luôn được mặc cùng nhau. Mỗi món chỉ có thể thuộc về một bộ đồ cố định.';

  @override
  String get outfitBuilder_stickers_placeholder => 'Nhãn dán sẽ sớm ra mắt.';

  @override
  String get closets_title => 'Tủ đồ của bạn';

  @override
  String closets_itemsSelected(int count) {
    return 'Đã chọn $count';
  }

  @override
  String get closets_tabAllItems => 'Tất cả';

  @override
  String get closets_tabByCloset => 'Theo Tủ đồ';

  @override
  String get allItems_searchHint => 'Tìm kiếm vật phẩm...';

  @override
  String get allItems_filterTooltip => 'Lọc';

  @override
  String get allItems_emptyCloset => 'Tủ đồ của bạn đang trống.';

  @override
  String get allItems_noItemsFound => 'Không tìm thấy vật phẩm nào phù hợp.';

  @override
  String get allItems_delete => 'Xoá';

  @override
  String get allItems_createOutfit => 'Tạo Trang phục';

  @override
  String get allItems_deleteDialogTitle => 'Xác nhận Xoá';

  @override
  String allItems_deleteDialogContent(int count) {
    return 'Bạn có chắc chắn muốn xoá vĩnh viễn $count vật phẩm đã chọn không?';
  }

  @override
  String get byCloset_addClosetHintTitle => 'Tạo Tủ đồ Mới';

  @override
  String get byCloset_addClosetHintDescription =>
      'Nhấn vào đây để tạo một tủ đồ mới, giúp bạn sắp xếp quần áo cho các mục đích khác nhau như \'Công sở\' hoặc \'Tập gym\'.';

  @override
  String get byCloset_addNewCloset => 'Thêm tủ đồ mới';

  @override
  String byCloset_itemCount(int count) {
    return '$count vật phẩm';
  }

  @override
  String get byCloset_itemCountError => 'Lỗi';

  @override
  String get byCloset_itemCountLoading => '...';

  @override
  String get byCloset_deleteDialogTitle => 'Xác nhận Xoá';

  @override
  String byCloset_deleteDialogContent(String closetName) {
    return 'Bạn có chắc chắn muốn xoá tủ đồ \"$closetName\" không?';
  }

  @override
  String get byCloset_limitReached => 'Đã đạt giới hạn tủ đồ (10).';

  @override
  String get closetForm_titleEdit => 'Sửa Tủ đồ';

  @override
  String get closetForm_titleAdd => 'Thêm Tủ đồ Mới';

  @override
  String get closetForm_saveButton => 'Lưu';

  @override
  String get closetForm_nameLabel => 'Tên Tủ đồ';

  @override
  String get closetForm_iconLabel => 'Chọn Biểu tượng';

  @override
  String get closetForm_colorLabel => 'Chọn Màu thẻ';

  @override
  String get calendar_title => 'Nhật ký Phong cách';

  @override
  String get calendar_addLogButton => 'Thêm';

  @override
  String get calendar_logWearHintTitle => 'Ghi lại Trang phục';

  @override
  String get calendar_logWearHintDescription =>
      'Chọn một ngày và nhấn vào đây để ghi lại những gì bạn đã mặc.';

  @override
  String get calendar_selectOutfits => 'Chọn Trang phục';

  @override
  String get calendar_selectItems => 'Chọn Vật phẩm';

  @override
  String get calendar_deleteDialogTitle => 'Xác nhận Xoá';

  @override
  String calendar_deleteDialogContent(int count) {
    return 'Bạn có chắc muốn xoá $count lựa chọn khỏi ngày này không?';
  }

  @override
  String calendar_deleteDialogContentOutfit(String outfitName) {
    return 'Bạn có chắc muốn xoá trang phục \'$outfitName\' khỏi nhật ký của ngày này không?';
  }

  @override
  String calendar_deleteDialogContentItem(String itemName) {
    return 'Bạn có chắc muốn xoá vật phẩm \'$itemName\' khỏi nhật ký của ngày này không?';
  }

  @override
  String get calendar_noItemsLogged =>
      'Không có vật phẩm nào được ghi lại cho ngày này.';

  @override
  String get calendar_outfitLabel => 'Trang phục';

  @override
  String get calendar_formatMonth => 'Tháng';

  @override
  String get calendar_formatTwoWeeks => '2 Tuần';

  @override
  String get calendar_formatWeek => '1 Tuần';

  @override
  String get home_greeting => 'Xin chào,';

  @override
  String get home_userNameDefault => 'Bạn';

  @override
  String get home_actionAddItem => 'Thêm mới\nvật phẩm';

  @override
  String get home_actionCreateCloset => 'Tạo mới\ntủ đồ';

  @override
  String get home_actionCreateOutfits => 'Tạo mới\ntrang phục';

  @override
  String get home_actionSavedOutfits => 'Trang phục\nđã có';

  @override
  String get home_weeklyJournalTitle => 'Nhật ký Tuần';

  @override
  String get home_weeklyJournalViewMore => 'Xem thêm';

  @override
  String get home_suggestionTitle => 'Gợi ý trang phục';

  @override
  String get mainScreen_bottomNav_home => 'Trang chủ';

  @override
  String get mainScreen_bottomNav_closets => 'Tủ đồ';

  @override
  String get mainScreen_bottomNav_addItems => 'Thêm đồ';

  @override
  String get mainScreen_bottomNav_outfits => 'Trang phục';

  @override
  String get mainScreen_bottomNav_profile => 'Hồ sơ';

  @override
  String get mainScreen_addItem_takePhoto => 'Chụp ảnh';

  @override
  String get mainScreen_addItem_fromAlbum => 'Từ album (tối đa 10)';

  @override
  String get mainScreen_tutorial_welcome =>
      'Chào mừng đến với MinCloset! Tôi là trợ lý thời trang cá nhân của bạn.';

  @override
  String get mainScreen_tutorial_introduce =>
      'Để tôi giới thiệu cho bạn tính năng đầu tiên và quan trọng nhất nhé!';

  @override
  String get mainScreen_tutorial_showAddItem =>
      'Hãy bắt đầu bằng cách thêm vật phẩm đầu tiên vào tủ đồ nào!';

  @override
  String get mainScreen_hint_addItem => 'Thêm Vật phẩm';

  @override
  String get mainScreen_hint_addItem_description =>
      'Nhấn vào đây để số hoá quần áo của bạn bằng cách chụp ảnh hoặc chọn từ thư viện.';

  @override
  String get suggestion_purposeHint => 'Mục đích? (vd: đi cà phê, hẹn hò...)';

  @override
  String suggestion_purposeLength(int current, int max) {
    return '$current/$max';
  }

  @override
  String get suggestion_editAndSaveButton => 'Sửa & Lưu';

  @override
  String get suggestion_placeholder =>
      'Mô tả mục đích của bạn và nhấn nút gửi để nhận gợi ý!';

  @override
  String get suggestion_weatherUnavailable =>
      'Không có dữ liệu thời tiết. Đây là một gợi ý chung.';

  @override
  String suggestion_lastUpdated(String datetime) {
    return 'Cập nhật lần cuối: $datetime';
  }

  @override
  String get itemDetail_titleEdit => 'Sửa vật phẩm';

  @override
  String get itemDetail_titleAdd => 'Thêm vật phẩm';

  @override
  String get itemDetail_favoriteTooltip_add => 'Thêm vào yêu thích';

  @override
  String get itemDetail_favoriteTooltip_remove => 'Bỏ yêu thích';

  @override
  String get itemDetail_deleteTooltip => 'Xoá vật phẩm';

  @override
  String get itemDetail_deleteDialogTitle => 'Xác nhận xoá';

  @override
  String itemDetail_deleteDialogContent(String itemName) {
    return 'Bạn có chắc muốn xoá vĩnh viễn vật phẩm \"$itemName\" không?';
  }

  @override
  String get itemDetail_saveButton => 'Lưu';

  @override
  String get itemDetail_form_imageError => 'Vui lòng thêm ảnh cho vật phẩm.';

  @override
  String get itemDetail_form_editButton => 'Sửa';

  @override
  String get itemDetail_form_removeBgButton => 'Tách nền';

  @override
  String get itemDetail_form_removeBgDialogTitle => 'Ảnh có thể đã được xử lý';

  @override
  String get itemDetail_form_removeBgDialogContent =>
      'Ảnh này có thể đã có nền trong suốt. Thực hiện lại có thể gây ra lỗi. Bạn có muốn tiếp tục không?';

  @override
  String get itemDetail_form_removeBgDialogContinue => 'Tiếp tục';

  @override
  String get itemDetail_form_errorReadingImage => 'Lỗi đọc định dạng ảnh.';

  @override
  String get itemDetail_form_timeoutError => 'Thao tác đã hết hạn sau 45 giây.';

  @override
  String itemDetail_form_unexpectedError(String error) {
    return 'Đã xảy ra lỗi không mong muốn: $error';
  }

  @override
  String get itemDetail_form_nameLabel => 'Tên vật phẩm *';

  @override
  String get itemDetail_form_closetLabel => 'Chọn tủ đồ *';

  @override
  String get itemDetail_form_categoryLabel => 'Danh mục *';

  @override
  String get itemDetail_form_categoryNoneSelected => 'Chưa chọn';

  @override
  String get itemDetail_form_colorLabel => 'Màu sắc';

  @override
  String get itemDetail_form_colorNotYet => 'Chưa có';

  @override
  String get itemDetail_form_seasonLabel => 'Mùa';

  @override
  String get itemDetail_form_occasionLabel => 'Dịp';

  @override
  String get itemDetail_form_materialLabel => 'Chất liệu';

  @override
  String get itemDetail_form_patternLabel => 'Hoạ tiết';

  @override
  String get itemDetail_form_priceLabel => 'Giá tiền';

  @override
  String get itemDetail_form_notesLabel => 'Ghi chú';
}
