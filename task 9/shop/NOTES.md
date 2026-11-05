# Notes

## Level 1
- Constructors touched to pass `total`: 2 (BooksScreen, CartBadge).
- Files touched: 3 (main.dart, books_screen.dart, cart_badge.dart).
- One Add tap printed 7 lines in the console: 1 x "BooksScreen build" + 6 x "row ..." (the whole screen and every row rebuilt, because setState in Shell marks everything under it dirty).

## Level 3: two ways to break provider on purpose

**The loud one** - `context.watch<Cart>().add(b)` inside the Add button's `onPressed`:

```
Tried to listen to a value exposed with provider, from outside of the widget tree.

This is likely caused by an event handler (like a button's onPressed) that called
Provider.of without passing `listen: false`.
```

Why: `watch` means "rebuild me when this changes", and that only makes sense while a widget is being built. A button callback runs later, outside `build`, so there is nothing to rebuild. Fix: use `context.read` in callbacks.

**The silent one** - `context.read<Cart>().count` in `CartBadge.build`:

No error, no warning, it compiles and runs. But the badge stays frozen at 0 forever (I saw it: three books were "Added", the badge still said 0). Nobody said "I depend on the cart", so nobody was rebuilt when `notifyListeners()` fired. Fix: use `context.watch` in `build`.

Rule: `watch` is a verb of `build`, `read` is a verb of `onPressed`.

## Level 4: select and Consumer, measured

Same model, same taps (Add one book, open the cart, press + three times), one line changed in one widget (`CartBadge`):

| Badge subscribes with | `badge build` after 3 presses of + | after removing the book |
|---|---|---|
| `context.watch<Cart>().count` | **3** | - |
| `context.select<Cart, int>((c) => c.count)` | **0** | **1** |

Why: `+` changes a quantity, not the number of distinct books, so `count` stays the same. `watch` rebuilds on every `notifyListeners()`; `select` compares the old and the new `count` and rebuilds only when they differ. Removing a book changes `count` (1 -> 0), so the badge builds once.

The total line on the Cart screen is a `Consumer<Cart>` whose `child` (an icon with the label "Total") is a `const` widget built once and passed through the builder with `child!`; only the sum text is rebuilt.

**A bug I found while measuring.** With `context.watch<Cart>().items.contains(b)` written directly in `BooksScreen.build`, every + press on the Cart screen printed "BooksScreen build" and all 6 "row ..." lines, even though the Books screen is hidden under the cart route (it is still alive in the Navigator stack). The whole screen subscribed, not just the button. Fix: wrap only the trailing Add/Added in a `Builder`, so the button gets its own context and only it subscribes ("subscribe where the value is shown, not where it is convenient"). After the fix nothing is printed on + presses.

## Level 5: Where does it live?

- **The cart** - *provided*. Three widgets on two different routes (the Books list, the badge in its AppBar, the Cart screen) all need the same object, and they sit far apart in the tree, so a `ChangeNotifierProvider` above `MaterialApp` puts it in one place and each widget subscribes where it shows the value.
- **The search text in the Books AppBar** - *ephemeral*. Only the Books screen reads it and nobody else cares; it is a plain `String` in that screen's `State`, and losing it when the screen is closed does no harm.
- **Whether the Cart screen's total is expanded or collapsed** - *ephemeral*. It is purely visual, one widget owns it (a `bool` in its own `State`), and no other widget or screen needs to know.
- **The theme mode (dark-mode switch)** - *provided*. `MaterialApp` has to read it from above every screen, while the switch itself would sit deep inside a settings screen; a small `ChangeNotifier` provided above `MaterialApp` lets the switch write it and `MaterialApp` watch it. (*Lifted* with `setState` in `Shell` would also work, but it would mean passing a callback down to the switch.)

Add and Clear: the model only returns a `bool` (`add`) or does the work (`clear`); the `SnackBar` and the confirmation dialog are decided in widgets. Nothing in `models/` mentions `BuildContext`, `SnackBar` or `Navigator`.
