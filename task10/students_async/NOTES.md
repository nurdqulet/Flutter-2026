# NOTES — Practice 10: The Data Arrives Later

> Lines marked **← FILL IN** must come from YOUR console. Run the app, copy the real text.

## Level 1 — order of events

Experiment code in `main()` (temporary, deleted afterwards):

```dart
void main() {
  print('A');
  Future.delayed(const Duration(seconds: 2), () => print('B'));
  print('C');
  final api = FakeApi();
  api.fetchStudents().then((l) => print('${l.length} students'));
  runApp(const App());
}
```

**Predicted:** `A`, `C`, then the first frame of the app. Two seconds later `B` and `6 students`.
(`main()` runs to the end first; the timer and the response are events that come later.)

**Actual:** ← FILL IN (paste what your console printed, in order)

Calling `fetchStudents()` three times in a row: the third one prints
`Unhandled Exception: Instance of 'NoConnectionException'` and the app keeps running.
Actual line: ← FILL IN

`sleep(const Duration(seconds: 2))` instead of `await Future.delayed(...)`: the first frame is
delayed by two seconds — the event loop is blocked, not waiting.

## Level 2 — mounted

Without both `if (!mounted) return;` lines, open the screen and press Back within 2 s.
First line of the error: ← FILL IN (starts with `setState() called after dispose()`)

## Level 3 — FutureBuilder

- `_future` is created once in `initState`; flipping the Switch ten times prints only `fetchStudents #1`.
- Broken version (`future: _api.fetchStudents()` inline in `build`): a spinner on every flip,
  the console counts `#2 #3 #4 …`, the third request fails.
- Swapping the first two branches (`hasData` before `hasError`) gives a spinner forever on error.

## Level 4 — countdown

- **With** `_sub.cancel()` in dispose (version B): press Back at 7 — the console stops at `tick 7`.
- **Without** `cancel()`: one second later `setState() called after dispose()` and the console keeps
  printing `tick 6, tick 5 … tick 0` with nobody on screen. That is the leak. Actual error line: ← FILL IN
- Version A (`StreamBuilder`): no `cancel` anywhere in my code, Back at 7, the console stops —
  `StreamBuilder` cancelled the subscription for me.

## Level 5 — errors that do not vanish

The naive version (what I first wrote):

```dart
onPressed: () { _api.save(n); Navigator.pop(context); }
```

`flutter analyze` flags it (`unawaited_futures`). Tapping Save twice anyway: the second tap pops the
screen as if it worked, and the console says `Unhandled Exception: Bad state: server rejected 6`.
**The user saw a success.**

Fix: `await` + `try / on StateError`, `context.mounted` after the await, pop only on success, the
message only on failure, and a `_saving` flag that disables the button while the request is in flight.

## Checklist before the defence

- [ ] `flutter analyze` → `No issues found!`
- [ ] `dart format .` has been run
- [ ] `screenshot_error.png` (the error view with Retry) committed
- [ ] `screenshot_countdown.png` (version B mid-count) committed
- [ ] All **← FILL IN** lines above are replaced with real console output
