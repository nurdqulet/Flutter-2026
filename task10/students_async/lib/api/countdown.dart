import 'package:flutter/foundation.dart';

/// Level 4: counts down from [from] to 0, one tick per second.
Stream<int> countdown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
    // The console is how we see the leak: ticks after the screen is gone.
    debugPrint('tick $i');
  }
}
