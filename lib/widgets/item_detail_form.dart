// lib/widgets/item_detail_form.dart
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/helpers/currency_input_formatter.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/services/number_formatting_service.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mincloset/widgets/category_selector.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';
import 'package:image/image.dart' as img;

class ItemDetailForm extends ConsumerStatefulWidget {
  final AddItemState itemState;
  final Function(String) onNameChanged;
  final Function(String?) onClosetChanged;
  final Function(String) onCategoryChanged;
  final Function(Set<String>) onColorsChanged;
  final Function(Set<String>) onSeasonsChanged;
  final Function(Set<String>) onOccasionsChanged;
  final Function(Set<String>) onMaterialsChanged;
  final Function(Set<String>) onPatternsChanged;
  final Function(String) onPriceChanged;
  final Function(String) onNotesChanged;
  final Function(Uint8List)? onImageUpdated;
  final Function()? onEditImagePressed;
  final ScrollController? scrollController;

  const ItemDetailForm({
    super.key,
    required this.itemState,
    required this.onNameChanged,
    required this.onClosetChanged,
    required this.onCategoryChanged,
    required this.onColorsChanged,
    required this.onSeasonsChanged,
    required this.onOccasionsChanged,
    required this.onMaterialsChanged,
    required this.onPatternsChanged,
    required this.onPriceChanged,
    required this.onNotesChanged,
    this.onImageUpdated,
    this.onEditImagePressed,
    this.scrollController,
  });

  @override
  ConsumerState<ItemDetailForm> createState() => _ItemDetailFormState();
}

class _ItemDetailFormState extends ConsumerState<ItemDetailForm> {
  // <<< QUẢN LÝ `TextEditingController` TRONG STATE >>>
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    // 1. Đọc các cài đặt hiện tại từ provider
    final settings = ref.read(profileProvider);
    String initialPriceText = '';

    // 2. Kiểm tra xem có giá trị price ban đầu không
    if (widget.itemState.price != null && widget.itemState.price! > 0) {
      // 3. Sử dụng NumberFormat để định dạng giá trị ban đầu
      final locale = settings.numberFormat == NumberFormatType.commaDecimal ? 'en_US' : 'vi_VN';
      final formatter = NumberFormat.decimalPattern(locale);
      initialPriceText = formatter.format(widget.itemState.price);
    }
    
    // 4. Khởi tạo các controller với giá trị đúng
    _nameController = TextEditingController(text: widget.itemState.name);
    _priceController = TextEditingController(text: initialPriceText);
    _notesController = TextEditingController(text: widget.itemState.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final closetsAsync = ref.watch(closetsProvider);
    final settings = ref.watch(profileProvider);

    String getCurrencySymbol(String currencyCode) { // hàm helper nhỏ để lấy ký hiệu tiền tệ
      switch (currencyCode) {
        case 'VND':
          return '₫';
        case 'USD':
          return '\$';
        case 'EUR':
          return '€';
        default:
          return currencyCode;
      }
    }

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Lớp 1: Khung ảnh
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Giữ lại nền trắng
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  // BỎ ĐI DECORATEDBOX, CHỈ GIỮ LẠI CLIPRRECT VÀ PADDING
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: widget.itemState.image != null
                          ? Image.file(widget.itemState.image!, fit: BoxFit.contain)
                          : (widget.itemState.imagePath != null
                              ? Image.file(File(widget.itemState.imagePath!), fit: BoxFit.contain)
                              : const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 60)),
                    ),
                  ),
                ),
              ),
              // Lớp 3: Nút Xóa nền
              if (widget.itemState.image != null || widget.itemState.imagePath != null)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: FilledButton.icon(
                    onPressed: () async {
                      // Phần logic lấy ảnh và hiển thị dialog xác nhận giữ nguyên
                      Uint8List? currentImageBytes;
                      if (widget.itemState.image != null) {
                        currentImageBytes = await widget.itemState.image!.readAsBytes();
                      } else if (widget.itemState.imagePath != null) {
                        currentImageBytes = await File(widget.itemState.imagePath!).readAsBytes();
                      }

                      if (currentImageBytes == null || !context.mounted) return;

                      bool shouldProceed = true;
                      try {
                        final image = img.decodeImage(currentImageBytes);
                        if (image?.hasAlpha == true) {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Image May Have Been Processed'),
                              content: const Text('This image might already have a transparent background. Proceeding again may cause errors. Do you want to continue?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                                  child: const Text('Continue'),

                                ),
                              ],
                            ),
                          );
                          shouldProceed = confirm ?? false;
                        }
                      } catch (e) {
                        shouldProceed = false;
                        ref.read(notificationServiceProvider).showBanner(message: 'Error reading image format.');
                      }

                      // PHẦN LOGIC TIMEOUT BẮT ĐẦU TẠI ĐÂY
                      if (shouldProceed && context.mounted) {
                        // Hiển thị một dialog loading để người dùng biết app đang xử lý
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => const PopScope(
                            canPop: false, // Ngăn người dùng back trong lúc xử lý
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );

                        try {
                          // Điều hướng đến trang xóa nền và áp dụng timeout
                          final removedBgBytes = await Navigator.pushNamed<Uint8List?>(
                            context,
                            AppRoutes.backgroundRemover,
                            arguments: currentImageBytes,
                          ).timeout(const Duration(seconds: 45)); // Đặt thời gian chờ là 45 giây

                          // Tắt dialog loading khi xử lý xong
                          if (context.mounted) Navigator.of(context).pop();

                          // Cập nhật ảnh nếu thành công
                          if (removedBgBytes != null) {
                            widget.onImageUpdated?.call(removedBgBytes);
                          }
                        } on TimeoutException {
                          // Xử lý khi hết thời gian chờ
                          if (context.mounted) Navigator.of(context).pop(); // Tắt dialog loading
                          if (context.mounted) {
                            ref.read(notificationServiceProvider).showBanner(
                                  message: 'Operation timed out after 45 seconds.',
                                );
                          }
                        } catch (e) {
                          // Xử lý các lỗi khác có thể xảy ra
                          if (context.mounted) Navigator.of(context).pop(); // Tắt dialog loading
                          if (context.mounted) {
                            ref.read(notificationServiceProvider).showBanner(
                                  message: 'An unexpected error occurred: $e',
                                );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.auto_fix_high_outlined, size: 18),
                    label: const Text('Remove BG'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: Colors.black.withValues(alpha:0.6),
                    ),
                  ),
                ),
              // Lớp 4: Nút EDIT
              if (widget.itemState.image != null || widget.itemState.imagePath != null)
                Positioned(
                  bottom: 12,
                  // Đặt nút Edit bên trái nút RemoveBG
                  // Bạn có thể điều chỉnh giá trị 'right' để có vị trí ưng ý
                  right: 140, 
                  child: FilledButton.icon(
                    onPressed: widget.onEditImagePressed, // Sử dụng callback mới
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: Colors.black.withValues(alpha:0.6),
                    ),
                  ),
                ),
              // Lớp 5: Vòng xoay loading khi phân tích AI (giữ nguyên)
              if (widget.itemState.isAnalyzing)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha:0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // <<< SỬ DỤNG CONTROLLER TỪ STATE >>>
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Item name *',
              border: OutlineInputBorder(),
            ),
            maxLength: 30,
            onChanged: widget.onNameChanged,
          ),
          const SizedBox(height: 16),
          closetsAsync.when(
            data: (closets) {
              if (closets.isEmpty) return const SizedBox.shrink();
              return DropdownButtonFormField<String>(
                value: widget.itemState.selectedClosetId,
                items: closets.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: widget.onClosetChanged,
                decoration: const InputDecoration(
                  labelText: 'Select closet *',
                  border: OutlineInputBorder(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Failed to load closet: $err'),
          ),
          const SizedBox(height: 16),
          CategorySelector(
            initialCategory: widget.itemState.selectedCategoryValue,
            onCategorySelected: widget.onCategoryChanged,
          ),
          MultiSelectChipField(
            label: 'Color',
            allOptions: AppOptions.colors,
            initialSelections: widget.itemState.selectedColors,
            onSelectionChanged: widget.onColorsChanged,
          ),
          MultiSelectChipField(
            label: 'Season',
            allOptions: AppOptions.seasons,
            initialSelections: widget.itemState.selectedSeasons,
            onSelectionChanged: widget.onSeasonsChanged,
          ),
          MultiSelectChipField(
            label: 'Occasion',
            allOptions: AppOptions.occasions,
            initialSelections: widget.itemState.selectedOccasions,
            onSelectionChanged: widget.onOccasionsChanged,
          ),
          MultiSelectChipField(
            label: 'Material',
            allOptions: AppOptions.materials,
            initialSelections: widget.itemState.selectedMaterials,
            onSelectionChanged: widget.onMaterialsChanged,
          ),
          MultiSelectChipField(
            label: 'Pattern',
            allOptions: AppOptions.patterns,
            initialSelections: widget.itemState.selectedPatterns,
            onSelectionChanged: widget.onPatternsChanged,
          ),

          const SizedBox(height: 24),
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Price',
              border: const OutlineInputBorder(),
              // Sử dụng 'suffix' thay vì 'suffixIcon'
              suffix: Padding(
                // Chỉ cần padding bên trái để tạo khoảng cách với số
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  getCurrencySymbol(settings.currency),
                  style: TextStyle(
                    // Có thể giảm cỡ chữ một chút để trông cân đối hơn
                    fontSize: 16, 
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
            keyboardType: TextInputType.number,
            // Thêm inputFormatters để áp dụng logic định dạng
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly, // Chỉ cho phép nhập số
              CurrencyInputFormatter(formatType: settings.numberFormat), // Áp dụng formatter của chúng ta
            ],
            onChanged: widget.onPriceChanged,
          ),
          
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            minLines: 3,
            maxLines: 10,
            textCapitalization: TextCapitalization.sentences,
            onChanged: widget.onNotesChanged,
          ),
        ],
      ),
    );
  }
}