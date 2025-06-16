// lib/widgets/city_preference_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/states/profile_page_state.dart';

// Chuyển thành ConsumerStatefulWidget để quản lý trạng thái loading/error cục bộ
class CityPreferenceDialog extends ConsumerStatefulWidget {
  const CityPreferenceDialog({super.key});

  @override
  ConsumerState<CityPreferenceDialog> createState() => _CityPreferenceDialogState();
}

class _CityPreferenceDialogState extends ConsumerState<CityPreferenceDialog> {
  late CityMode _selectedMode;
  late TextEditingController _cityController;
  bool _isLoading = false; // Trạng thái loading khi xác thực thành phố
  String? _errorMessage; // Trạng thái lỗi nếu tên thành phố sai

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(profileProvider);
    _selectedMode = initialState.cityMode;
    _cityController = TextEditingController(text: initialState.manualCity);
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
  
  // Hàm xử lý việc lưu
  Future<void> _onSavePressed() async {
    final notifier = ref.read(profileProvider.notifier);
    final enteredCity = _cityController.text.trim();

    if (_selectedMode == CityMode.manual) {
      if (enteredCity.isEmpty) {
        setState(() { _errorMessage = 'Vui lòng nhập tên thành phố.'; });
        return;
      }
      
      // Bắt đầu xác thực
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Gọi API thời tiết để kiểm tra tên thành phố
        final weatherRepo = ref.read(weatherRepositoryProvider);
        await weatherRepo.getWeather(enteredCity);
        
        // Nếu không có lỗi, lưu lại
        await notifier.updateCityPreference(_selectedMode, enteredCity);
        if (mounted) Navigator.of(context).pop();

      } catch (e) {
        // Nếu có lỗi (ví dụ 404), báo lỗi cho người dùng
        setState(() {
          _isLoading = false;
          _errorMessage = 'Không tìm thấy thành phố này. Vui lòng kiểm tra lại.';
        });
      }

    } else { // Chế độ Auto
      await notifier.updateCityPreference(_selectedMode, null);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tùy chọn Thành phố'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<CityMode>(
            title: const Text('Tự động theo vị trí'),
            value: CityMode.auto,
            groupValue: _selectedMode,
            onChanged: (value) => setState(() => _selectedMode = value!),
          ),
          RadioListTile<CityMode>(
            title: const Text('Nhập thủ công'),
            value: CityMode.manual,
            groupValue: _selectedMode,
            onChanged: (value) => setState(() => _selectedMode = value!),
          ),
          if (_selectedMode == CityMode.manual)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Tên thành phố',
                  // Hiển thị lỗi ngay trên TextField
                  errorText: _errorMessage, 
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        // Nút Lưu giờ có trạng thái loading
        ElevatedButton(
          onPressed: _isLoading ? null : _onSavePressed,
          child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Text('Lưu'),
        ),
      ],
    );
  }
}