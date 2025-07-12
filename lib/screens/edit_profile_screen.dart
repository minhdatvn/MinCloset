// lib/screens/edit_profile_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';
import 'package:mincloset/widgets/page_scaffold.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
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
    _nameController.text = initialState.userName ?? '';
    _selectedGender = initialState.gender;
    _selectedDOB = initialState.dob;
    if (initialState.height != null) {
      _heightController.text = initialState.height.toString();
    }
    if (initialState.weight != null) {
      _weightController.text = initialState.weight.toString();
    }
    _selectedStyles = Set.from(initialState.personalStyles);
    _selectedFavoriteColors = Set.from(initialState.favoriteColors);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final navigator = Navigator.of(context);
    final data = {
      'name': _nameController.text.trim(),
      'gender': _selectedGender,
      'dob': _selectedDOB,
      'height': int.tryParse(_heightController.text),
      'weight': int.tryParse(_weightController.text),
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
                  onDateTimeChanged: (DateTime newDate) {
                    tempDate = newDate;
                  },
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
            _buildSectionTitle('Basic info '),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              items: _genders
                  .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                // <<< SỬA LỖI THỤT LỀ >>>
                decoration: const InputDecoration(
                  labelText: 'Birthday',
                  contentPadding: EdgeInsets.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _selectedDOB == null
                        ? 'Not selected'
                        : DateFormat('dd/MM/yyyy').format(_selectedDOB!),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(labelText: 'Height (cm)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
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
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}