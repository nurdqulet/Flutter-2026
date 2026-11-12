import 'dart:async';

import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

/// Levels 2 and 5: the four states by hand, and an honest Save button.
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students; // null = not loaded yet
  Object? _error; // non-null = failed
  final _api = FakeApi(); // use FakeApi(empty: true) to see the empty state
  bool _saving = false; // Level 5: a save is in flight

  @override
  void initState() {
    super.initState();
    // initState is synchronous: the framework will not wait for a Future.
    // unawaited() says out loud "I know, on purpose" (unawaited_futures lint).
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return; // the screen may be gone by now
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  // Level 5: await + try/on, pop only on success, message only on failure.
  Future<void> _save() async {
    final n = _students!.length;
    setState(() => _saving = true);
    try {
      await _api.save(n);
      if (!mounted) return; // State: check mounted, not context.mounted
      Navigator.pop(context);
    } on StateError catch (e) {
      if (!mounted) return; // State: check mounted, not context.mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_error != null) {
      body = ErrorView(onRetry: _load);
    } else if (_students == null) {
      body = const LoadingView();
    } else if (_students!.isEmpty) {
      body = const EmptyView();
    } else {
      body = StudentList(_students!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('By hand')),
      body: body,
      floatingActionButton: FloatingActionButton(
        // disabled while loading, failed, or while a save is in flight
        onPressed: (_students == null || _saving) ? null : _save,
        child: _saving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
      ),
    );
  }
}
