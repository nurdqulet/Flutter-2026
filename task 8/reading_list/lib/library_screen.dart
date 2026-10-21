import 'package:flutter/material.dart';

import 'models/book.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed];

  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((book) => book.read).toList(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${_visible.length})')),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Filter chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filter == Filter.all,
                onSelected: (_) {
                  setState(() {
                    _filter = Filter.all;
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Unread'),
                selected: _filter == Filter.unread,
                onSelected: (_) {
                  setState(() {
                    _filter = Filter.unread;
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Read'),
                selected: _filter == Filter.read,
                onSelected: (_) {
                  setState(() {
                    _filter = Filter.read;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Books list
          Expanded(
            child: ListView.builder(
              itemCount: _visible.length,
              itemBuilder: (context, index) {
                final book = _visible[index];

                return CheckboxListTile(
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  value: book.read,
                  onChanged: (value) {
                    setState(() {
                      book.read = value ?? false;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
