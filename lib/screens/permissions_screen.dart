// lib/screens/permissions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/providers/flow_providers.dart';
import 'package:mincloset/src/providers/notification_providers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  Future<void> _requestPermissions(BuildContext context, WidgetRef ref) async {
    await ref.read(localNotificationServiceProvider).requestPermissions();
    // Request the necessary permissions at once
    await [
      Permission.camera,
      Permission.locationWhenInUse,
    ].request();

    // After the user responds, mark that the permission screen has been seen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_permissions_screen', true);

    // This line will now work correctly
    ref.read(permissionsSeenProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.shield_outlined, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                l10n.permissions_title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.permissions_description,
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildPermissionItem(
                Icons.notifications_outlined,
                l10n.permissions_notifications_title,
                l10n.permissions_notifications_desc,
              ),
              const SizedBox(height: 16),
              _buildPermissionItem(
                Icons.camera_alt_outlined,
                l10n.permissions_camera_title,
                l10n.permissions_camera_desc,
              ),
              const SizedBox(height: 16),
              _buildPermissionItem(
                Icons.location_on_outlined,
                l10n.permissions_location_title,
                l10n.permissions_location_desc,
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _requestPermissions(context, ref),
                child: Text(l10n.permissions_continue_button, style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}