import 'package:flutter/material.dart';

import '../models/photo_event.dart';
import '../utils/dialogs.dart';
import '../utils/format.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, this.event});

  final PhotoEvent? event;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final PhotoEvent _base;
  late final TextEditingController _titleController;
  late final TextEditingController _placeController;
  late final TextEditingController _limitController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;

  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _dateFocus = FocusNode();
  final _timeFocus = FocusNode();
  final _categoryFocus = FocusNode();

  EventCategory? _category;
  DateTime? _day;
  TimeOfDay? _time;
  late bool _online;
  late final Object _initialValues;

  bool _saving = false;
  bool _allowPop = false;
  bool _askingDiscard = false;

  bool get _editing => widget.event != null;

  DateTime? get _combinedDate {
    final day = _day;
    final time = _time;

    if (day == null || time == null) {
      return null;
    }

    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  Object get _values => (
    _titleController.text,
    _placeController.text,
    _limitController.text,
    _descriptionController.text,
    _category,
    _combinedDate,
    _online,
  );

  bool get _dirty => _values != _initialValues;

  @override
  void initState() {
    super.initState();

    _base = widget.event ?? const PhotoEvent.empty();
    _category = _editing ? _base.category : null;
    _online = _base.online;

    final date = _base.when;

    if (date != null) {
      _day = DateTime(date.year, date.month, date.day);
      _time = TimeOfDay.fromDateTime(date);
    }

    _titleController = TextEditingController(text: _base.title);
    _placeController = TextEditingController(text: _base.place);
    _limitController = TextEditingController(text: _base.limit.toString());
    _descriptionController = TextEditingController(
      text: _base.description ?? '',
    );
    _dateController = TextEditingController(
      text: date == null ? '' : formatDateTime(date).split(',').first,
    );
    _timeController = TextEditingController(
      text: date == null ? '' : _formatTime(TimeOfDay.fromDateTime(date)),
    );

    _initialValues = _values;
  }

  @override
  void dispose() {
    for (final controller in [
      _titleController,
      _placeController,
      _limitController,
      _descriptionController,
      _dateController,
      _timeController,
    ]) {
      controller.dispose();
    }

    for (final focus in [
      _titleFocus,
      _placeFocus,
      _limitFocus,
      _descriptionFocus,
      _dateFocus,
      _timeFocus,
      _categoryFocus,
    ]) {
      focus.dispose();
    }

    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String? _validateTitle(String? value) {
    final title = (value ?? '').trim();

    if (title.length < 3 || title.length > 60) {
      return 'Use 3–60 characters';
    }

    return null;
  }

  String? _validatePlace(String? value) {
    final place = (value ?? '').trim();

    if (place.isEmpty) {
      return _online ? 'Enter a meeting link' : 'Enter a place';
    }

    if (_online && !place.contains('://')) {
      return 'The link must contain ://';
    }

    return null;
  }

  String? _validateLimit(String? value) {
    final limit = int.tryParse((value ?? '').trim());

    if (limit == null || limit < 1 || limit > 500) {
      return 'Enter a whole number from 1 to 500';
    }

    if (limit < _base.count) {
      return 'Cannot be below ${_base.count} registered participants';
    }

    return null;
  }

  String? _validateCategory(EventCategory? value) {
    return value == null ? 'Choose a category' : null;
  }

  String? _validateDate(String? value) {
    return _day == null ? 'Choose a date' : null;
  }

  String? _validateTime(String? value) {
    if (_time == null) {
      return 'Choose a time';
    }

    final date = _combinedDate;

    if (!_editing && date != null && !date.isAfter(DateTime.now())) {
      return 'Choose a future date and time';
    }

    return null;
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();

    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted) {
      return;
    }

    if (picked == null) {
      return;
    }

    setState(() {
      _day = picked;
      _dateController.text = formatDateTime(picked).split(',').first;
    });
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();

    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );

    if (!mounted) {
      return;
    }

    if (picked == null) {
      return;
    }

    setState(() {
      _time = picked;
      _timeController.text = _formatTime(picked);
    });
  }

  Future<void> _close(PhotoEvent? result) async {
    setState(() {
      _allowPop = true;
    });

    // Let PopScope rebuild before requesting the pop.
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) {
      return;
    }

    Navigator.pop<PhotoEvent>(context, result);
  }

  Future<void> _requestLeave() async {
    if (_saving || _askingDiscard) {
      return;
    }

    _askingDiscard = true;

    final confirmed = await confirmAction(
      context,
      title: 'Discard changes?',
      message: 'Your unsaved changes will be lost.',
      actionLabel: 'Discard',
    );

    if (!mounted) {
      return;
    }

    _askingDiscard = false;

    if (confirmed == true) {
      await _close(null);
    }
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    final valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
      return;
    }

    final category = _category;
    final date = _combinedDate;

    if (category == null || date == null) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
    });

    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    final description = _descriptionController.text.trim();

    final result = _base.copyWith(
      id: _editing
          ? _base.id
          : DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: category,
      when: date,
      place: _placeController.text.trim(),
      limit: int.parse(_limitController.text.trim()),
      online: _online,
      description: description,
      clearDescription: description.isEmpty,
    );

    await _close(result);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<PhotoEvent>(
      canPop: _allowPop || (!_dirty && !_saving),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _requestLeave();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_editing ? 'Edit event' : 'New event')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () {
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                focusNode: _titleFocus,
                enabled: !_saving,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: _validateTitle,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EventCategory>(
                initialValue: _category,
                focusNode: _categoryFocus,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: _validateCategory,
                items: [
                  for (final category in EventCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                ],
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _category = value;
                        });
                      },
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Online event'),
                subtitle: const Text('Use a meeting link instead of a place'),
                contentPadding: EdgeInsets.zero,
                value: _online,
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _online = value ?? false;
                        });
                      },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _placeController,
                focusNode: _placeFocus,
                enabled: !_saving,
                decoration: InputDecoration(
                  labelText: _online ? 'Meeting link' : 'Place',
                  hintText: _online ? 'https://example.com/meeting' : null,
                  border: const OutlineInputBorder(),
                ),
                validator: _validatePlace,
                keyboardType: _online ? TextInputType.url : TextInputType.text,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _limitController,
                focusNode: _limitFocus,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Participant limit',
                  border: OutlineInputBorder(),
                ),
                validator: _validateLimit,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _dateFocus.requestFocus(),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                focusNode: _dateFocus,
                enabled: !_saving,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_month),
                  border: OutlineInputBorder(),
                ),
                validator: _validateDate,
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.next,
                onTap: _pickDate,
                onFieldSubmitted: (_) => _timeFocus.requestFocus(),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                focusNode: _timeFocus,
                enabled: !_saving,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  suffixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
                validator: _validateTime,
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.next,
                onTap: _pickTime,
                onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                focusNode: _descriptionFocus,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                validator: (_) => null,
                minLines: 2,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _descriptionFocus.unfocus(),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
