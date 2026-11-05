import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: const [CartBadge()],
      ),
      body: ListView(
        children: books.map((b) {
          debugPrint('row ${b.title}');
          return ListTile(
            title: Text(b.title),
            subtitle: Text(b.author),
            // Builder gives this button its OWN context, so only the button
            // subscribes to the cart, not the whole screen.
            trailing: Builder(
              builder: (context) => context.watch<Cart>().items.contains(b)
                  ? const Text('Added')
                  : OutlinedButton(
                      onPressed: () => context.read<Cart>().add(b),
                      child: const Text('Add'),
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
