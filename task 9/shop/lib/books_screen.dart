import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  // Ephemeral state: only this screen cares about the search text.
  String _query = '';

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final q = _query.toLowerCase();
    final visible = books
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search books',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: const [CartBadge()],
      ),
      body: ListView(
        children: visible.map((b) {
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
                      onPressed: () {
                        // The model only answers true/false; the widget
                        // decides what to show.
                        final ok = context.read<Cart>().add(b);
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added')),
                          );
                        }
                      },
                      child: const Text('Add'),
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
