import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

enum _Version { a, b }

/// Level 4: a countdown, two ways.
class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  _Version _version = _Version.a;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<_Version>(
              segments: const [
                ButtonSegment(value: _Version.a, label: Text('A: StreamBuilder')),
                ButtonSegment(value: _Version.b, label: Text('B: listen')),
              ],
              selected: {_version},
              onSelectionChanged: (s) => setState(() => _version = s.first),
            ),
          ),
          // Each version is its own widget with its own State, so switching
          // creates a fresh stream (an async* stream can be listened to once).
          Expanded(
            child: _version == _Version.a
                ? const _VersionA(key: ValueKey('a'))
                : const _VersionB(key: ValueKey('b')),
          ),
        ],
      ),
    );
  }
}

/// Version A: the stream is a field, StreamBuilder listens and cancels for us.
class _VersionA extends StatefulWidget {
  const _VersionA({super.key});

  @override
  State<_VersionA> createState() => _VersionAState();
}

class _VersionAState extends State<_VersionA> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _stream,
      builder: (context, snapshot) {
        return Center(
          child: Text(
            '${snapshot.data ?? 10}',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        );
      },
    );
  }
}

/// Version B: we listen ourselves, so we must cancel ourselves.
class _VersionB extends StatefulWidget {
  const _VersionB({super.key});

  @override
  State<_VersionB> createState() => _VersionBState();
}

class _VersionBState extends State<_VersionB> {
  int _left = 10;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((i) => setState(() => _left = i));
  }

  @override
  void dispose() {
    // Without this line the generator keeps ticking for a dead screen.
    unawaited(_sub.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$_left',
        style: Theme.of(context).textTheme.displayLarge,
      ),
    );
  }
}
