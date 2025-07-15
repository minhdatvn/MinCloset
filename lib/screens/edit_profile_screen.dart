// lib/screens/edit_profile_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/services/unit_conversion_service.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';
import 'package:mincloset/widgets/page_scaffold.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // <<< THAY ĐỔI 1: THÊM CONTROLLER CHO FEET VÀ INCHES >>>
  final _nameController = TextEditingController();
  final _heightCmController = TextEditingController();
  final _heightFeetController = TextEditingController();
  final _heightInchesController = TextEditingController();
  final _weightController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDOB;
  Set<String> _selectedStyles = {};
  Set<String> _selectedFavoriteColors = {};

  final _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(profileProvider);
    final unitConverter = ref.read(unitConversionServiceProvider);

    _nameController.text = initialState.userName ?? '';
    _selectedGender = initialState.gender;
    _selectedDOB = initialState.dob;
    _selectedStyles = Set.from(initialState.personalStyles);
    _selectedFavoriteColors = Set.from(initialState.favoriteColors);

    // <<< THAY ĐỔI 2: CẬP NHẬT LOGIC KHỞI TẠO CHO CHIỀU CAO >>>
    if (initialState.height != null) {
      // Dùng hàm mới để chuyển đổi
      final heightMap = unitConverter.cmToFeetAndInches(initialState.height!);
      _heightCmController.text = initialState.height.toString();
      _heightFeetController.text = heightMap['feet'].toString();
      _heightInchesController.text = heightMap['inches'].toString();
    }

    if (initialState.weight != null) {
      if (initialState.weightUnit == WeightUnit.kg) {
        _weightController.text = initialState.weight.toString();
      } else {
        _weightController.text = unitConverter.kgToLbs(initialState.weight!).toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightCmController.dispose();
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // <<< THAY ĐỔI 3: CẬP NHẬT LOGIC LƯU PROFILE >>>
  Future<void> _saveProfile() async {
    final navigator = Navigator.of(context);
    final profileState = ref.read(profileProvider);
    final unitConverter = ref.read(unitConversionServiceProvider);

    int? heightToSave;
    if (profileState.heightUnit == HeightUnit.cm) {
      heightToSave = int.tryParse(_heightCmController.text);
    } else {
      // Đọc từ 2 ô feet và inches, sau đó gộp lại và chuyển về cm
      final feet = int.tryParse(_heightFeetController.text) ?? 0;
      final inches = int.tryParse(_heightInchesController.text) ?? 0;
      heightToSave = unitConverter.feetAndInchesToCm(feet, inches);
    }
    
    int? weightToSave = int.tryParse(_weightController.text);
    if (weightToSave != null && profileState.weightUnit == WeightUnit.lbs) {
      weightToSave = unitConverter.lbsToKg(weightToSave);
    }

    final data = {
      'name': _nameController.text.trim(),
      'gender': _selectedGender,
      'dob': _selectedDOB,
      'height': heightToSave,
      'weight': weightToSave,
      'personalStyles': _selectedStyles,
      'favoriteColors': _selectedFavoriteColors,
    };
    await ref.read(profileProvider.notifier).updateProfileInfo(data);
    if (mounted) navigator.pop();
  }

  void _selectDate() {
    DateTime tempDate = _selectedDOB ?? DateTime.now().subtract(const Duration(days: 365 * 20));
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (newDate) { tempDate = newDate; },
                  initialDateTime: _selectedDOB ?? DateTime(2000),
                  minimumDate: DateTime(1920),
                  maximumDate: DateTime.now(),
                ),
              ),
              CupertinoButton(
                child: const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: () {
                  setState(() => _selectedDOB = tempDate);
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    return PageScaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Basic info'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Birthday', contentPadding: EdgeInsets.zero),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _selectedDOB == null ? 'Not selected' : DateFormat('dd/MM/yyyy').format(_selectedDOB!),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // <<< THAY ĐỔI 4: HIỂN THỊ Ô NHẬP LIỆU ĐỘNG >>>
            if (profileState.heightUnit == HeightUnit.cm)
              TextFormField(
                controller: _heightCmController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              )
            else
              // Bọc các ô nhập liệu ft/in trong một InputDecorator
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Height',
                  border: OutlineInputBorder(), // Thêm đường viền
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ô nhập Feet
                    Expanded(
                      child: TextFormField(
                        controller: _heightFeetController,
                        textAlign: TextAlign.center, // Căn giữa cho đẹp
                        decoration: const InputDecoration(
                          border: InputBorder.none, // Bỏ đường viền riêng
                          suffixText: 'ft', // Thêm suffix "ft"
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Ngăn cách
                    Text("'", style: TextStyle(fontSize: 24, color: Colors.grey.shade600)),
                    const SizedBox(width: 8),
                    // Ô nhập Inches
                    Expanded(
                      child: TextFormField(
                        controller: _heightInchesController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          suffixText: 'in', // Thêm suffix "in"
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight (${profileState.weightUnit == WeightUnit.kg ? "kg" : "lbs"})',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const Divider(height: 48),
            _buildSectionTitle('Interests & Style'),
            const SizedBox(height: 8),
            MultiSelectChipField(
              label: 'Personal style',
              allOptions: AppOptions.personalStyles,
              initialSelections: _selectedStyles,
              onSelectionChanged: (selections) => setState(() => _selectedStyles = selections),
            ),
            MultiSelectChipField(
              label: 'Favorite colors',
              allOptions: AppOptions.colors,
              initialSelections: _selectedFavoriteColors,
              onSelectionChanged: (selections) => setState(() => _selectedFavoriteColors = selections),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold));
  }
}