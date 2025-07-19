// lib/screens/edit_profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/l10n/app_localizations.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/auth_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/services/unit_conversion_service.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/widgets/section_header.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _heightCmController = TextEditingController();
  final _heightFeetController = TextEditingController();
  final _heightInchesController = TextEditingController();
  final _weightController = TextEditingController();
  
  String? _selectedGender;
  DateTime? _selectedDOB;
  Set<String> _selectedStyles = {};
  Set<String> _selectedFavoriteColors = {};

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
    
    if (initialState.height != null) {
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

  Future<void> _saveProfile() async {
    // ... logic lưu profile không đổi
    final navigator = Navigator.of(context);
    final profileState = ref.read(profileProvider);
    final unitConverter = ref.read(unitConversionServiceProvider);

    int? heightToSave;
    if (profileState.heightUnit == HeightUnit.cm) {
      heightToSave = int.tryParse(_heightCmController.text);
    } else {
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
    // ... logic chọn ngày không đổi
    final l10n = AppLocalizations.of(context)!;
    DateTime tempDate = _selectedDOB ?? DateTime.now().subtract(const Duration(days: 365 * 20));
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (newDate) { tempDate = newDate; },
                  initialDateTime: _selectedDOB ?? DateTime(2000),
                  minimumDate: DateTime(1920),
                  maximumDate: DateTime.now(),
                ),
              ),
              CupertinoButton(
                child: Text(l10n.editProfile_saveButton, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  // <<< BẮT ĐẦU VÙNG CODE MỚI >>>

  /// Xây dựng giao diện cho khu vực tài khoản, thay đổi tùy theo trạng thái đăng nhập.
  Widget _buildAccountSection(User? user) {
    final isLoading = ref.watch(backupRestoreLoadingProvider);
    final lastBackupAsyncValue = ref.watch(lastBackupProvider);
    if (user == null) {
      return Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "Sign in to back up your data and sync across devices.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(authRepositoryProvider).signInWithGoogle();
                },
                icon: Image.asset('assets/images/google_logo.png', height: 24.0),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Nếu đã đăng nhập
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text("Account"),
            subtitle: Text(user.email ?? "No email"),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud_sync_outlined, color: Colors.grey),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Backup & Restore", style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        lastBackupAsyncValue.when(
                          data: (date) => Text(
                            date != null 
                              ? "Last backup: ${DateFormat.yMd().add_jms().format(date)}"
                              : "Last backup: Not yet available",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          loading: () => const Text("Checking..."),
                          error: (e, s) => const Text("Error loading backup time"),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Nút Backup
                    OutlinedButton(
                      onPressed: isLoading ? null : () async {
                        ref.read(backupRestoreLoadingProvider.notifier).state = true;
                        try {
                          await ref.read(backupServiceProvider).performBackup();
                          ref.read(notificationServiceProvider).showBanner(
                            message: "Backup completed successfully!",
                            type: NotificationType.success,
                          );
                          ref.invalidate(lastBackupProvider); // Làm mới lại thời gian backup
                        } catch (e) {
                          ref.read(notificationServiceProvider).showBanner(
                            message: "Backup failed: ${e.toString()}",
                          );
                        } finally {
                          if(mounted) {
                            ref.read(backupRestoreLoadingProvider.notifier).state = false;
                          }
                        }
                      }, 
                      child: const Text("Backup")
                    ),
                    const SizedBox(width: 8),
                    // Nút Restore
                    FilledButton(
                      onPressed: isLoading ? null : () {
                        // TODO: Implement Restore Logic
                      }, 
                      child: const Text("Restore")
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade700),
            title: Text("Logout", style: TextStyle(color: Colors.red.shade700)),
            onTap: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final l10n = AppLocalizations.of(context)!;
    final genders = {
      l10n.gender_male: 'Male',
      l10n.gender_female: 'Female',
      l10n.gender_other: 'Other'
    };
    
    // <<< THÊM MỚI: Lắng nghe trạng thái đăng nhập >>>
    final authState = ref.watch(authStateChangesProvider);

    return PageScaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile_title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(l10n.editProfile_saveButton, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // <<< THÊM MỚI: Hiển thị khối tài khoản ở đây >>>
            authState.when(
              data: (user) => _buildAccountSection(user),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
            const Divider(height: 48),

            SectionHeader(title: l10n.editProfile_basicInfo_sectionHeader),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.editProfile_fullName_label),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              items: genders.keys.map((g) => DropdownMenuItem(value: genders[g], child: Text(g))).toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
              decoration: InputDecoration(labelText: l10n.editProfile_gender_label),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(labelText: l10n.editProfile_birthday_label, contentPadding: EdgeInsets.zero),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _selectedDOB == null ? l10n.editProfile_notSelected_label : DateFormat('dd/MM/yyyy').format(_selectedDOB!),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (profileState.heightUnit == HeightUnit.cm)
              TextFormField(
                controller: _heightCmController,
                decoration: InputDecoration(labelText: l10n.editProfile_height_cm_label),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              )
            else
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.editProfile_height_ft_in_label,
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightFeetController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          suffixText: 'ft',
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("'", style: TextStyle(fontSize: 24, color: Colors.grey.shade600)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _heightInchesController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          suffixText: 'in',
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
                labelText: '${l10n.editProfile_weight_label} (${profileState.weightUnit == WeightUnit.kg ? "kg" : "lbs"})',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const Divider(height: 48),
            SectionHeader(title: l10n.editProfile_interests_sectionHeader),
            const SizedBox(height: 8),
            MultiSelectChipField(
              label: l10n.editProfile_personalStyle_label,
              allOptions: AppOptions.personalStyles,
              initialSelections: _selectedStyles,
              onSelectionChanged: (selections) => setState(() => _selectedStyles = selections),
            ),
            MultiSelectChipField(
              label: l10n.editProfile_favoriteColors_label,
              allOptions: AppOptions.colors,
              initialSelections: _selectedFavoriteColors,
              onSelectionChanged: (selections) => setState(() => _selectedFavoriteColors = selections),
            ),
          ],
        ),
      ),
    );
  }
}