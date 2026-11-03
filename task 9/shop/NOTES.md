# Notes

## Level 1
- Constructors touched to pass `total`: 2 (BooksScreen, CartBadge).
- Files touched: 3 (main.dart, books_screen.dart, cart_badge.dart).
- One Add tap printed 7 lines in the console: 1 x "BooksScreen build" + 6 x "row ..." (the whole screen and every row rebuilt, because setState in Shell marks everything under it dirty).