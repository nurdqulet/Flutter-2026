import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _prefs = SharedPreferencesAsync();
  final _picker = ImagePicker();
  File? _avatar;

  @override
  void initState() {
    super.initState();
    unawaited(_loadAvatar());
  }

  Future<void> _loadAvatar() async {
    final path = await _prefs.getString('avatarPath');
    if (path == null) return;
    final file = File(path);
    if (!await file.exists()) return; // the file may be gone: no photo
    if (!mounted) return;
    setState(() => _avatar = file);
  }

  Future<void> _choosePhoto() => _pick(ImageSource.gallery);

  Future<void> _takePhoto() async {
    // asked at the moment of the tap, never in initState
    final status = await Permission.camera.request();
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted || PermissionStatus.limited:
        await _pick(ImageSource.camera);
      case PermissionStatus.denied:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The camera is needed to take a profile photo. '
              'You can still choose one from the gallery.',
            ),
          ),
        );
      case PermissionStatus.permanentlyDenied:
        await _showSettingsDialog();
      case PermissionStatus.restricted || PermissionStatus.provisional:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The camera is restricted on this device.'),
          ),
        );
    }
  }

  Future<void> _showSettingsDialog() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera is off'),
        content: const Text(
          'Camera access was denied. To take a photo, allow it in the '
          'app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open ?? false) await openAppSettings();
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return; // Cancel
    final dir = await getApplicationDocumentsDirectory();
    final saved = await File(picked.path).copy('${dir.path}/avatar.jpg');
    await _prefs.setString('avatarPath', saved.path);
    await FileImage(saved).evict(); // same path, new picture
    if (!mounted) return;
    setState(() => _avatar = saved);
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _avatar;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage: avatar == null ? null : FileImage(avatar),
              child: avatar == null
                  ? const Text('U', style: TextStyle(fontSize: 48))
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _choosePhoto,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose photo'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Take photo'),
            ),
          ],
        ),
      ),
    );
  }
}
