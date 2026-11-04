import 'package:flutter/foundation.dart';
import 'book.dart';


class Cart extends ChangeNotifier {
  final List<Book> _items = [];


  List<Book> get items => List.unmodifiable(_items);
  int get count => _items.length;
  int get total => _items.fold(0, (sum, b) => sum + b.price);

  bool add(Book b) {
    if (_items.contains(b)) return false;
    _items.add(b);
    notifyListeners();
    return true;
  }

  void remove(Book b) {
    _items.remove(b);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}