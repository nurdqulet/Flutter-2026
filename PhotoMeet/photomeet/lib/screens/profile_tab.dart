import 'package:flutter/material.dart';

import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.joinedCount,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeChanged,
  });

  final Profile profile;
  final int joinedCount;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _groupController;

  final _nameFocus = FocusNode();
  final _groupFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _groupController = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.profile.name != widget.profile.name) {
      _nameController.text = widget.profile.name;
    }

    if (oldWidget.profile.group != widget.profile.group) {
      _groupController.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _nameFocus.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if ((value ?? '').trim().length > 40) {
      return 'Use no more than 40 characters';
    }
    return null;
  }

  String? _validateGroup(String? value) {
    final group = (value ?? '').trim();

    if (group.isEmpty) {
      return null;
    }

    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9 -]{1,19}$').hasMatch(group)) {
      return 'Use 2–20 letters, numbers, spaces or hyphens';
    }

    return null;
  }

  void _save() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    widget.onProfileChanged(
      widget.profile.copyWith(
        name: _nameController.text.trim(),
        group: _groupController.text.trim(),
      ),
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.account_circle, size: 72),
        const SizedBox(height: 16),
        Text('Your profile', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Your name for event registration',
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                onFieldSubmitted: (_) {
                  _save();
                  _groupFocus.requestFocus();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groupController,
                focusNode: _groupFocus,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  hintText: 'For example: IT-2301',
                  border: OutlineInputBorder(),
                ),
                validator: _validateGroup,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                onFieldSubmitted: (_) {
                  _save();
                  _groupFocus.unfocus();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('You are on ${widget.joinedCount} lists'),
        const SizedBox(height: 24),
        Text('Appearance', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(switch (mode) {
                  ThemeMode.system => 'System',
                  ThemeMode.light => 'Light',
                  ThemeMode.dark => 'Dark',
                }),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeChanged(mode),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Press Next or Done on the keyboard to save your profile.'),
      ],
    );
  }
}
