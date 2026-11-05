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
