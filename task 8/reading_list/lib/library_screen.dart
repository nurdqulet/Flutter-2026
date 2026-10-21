import 'package:flutter/material.dart';

import 'models/book.dart';
import 'widgets/book_tile.dart';

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

  Widget _statItem(BuildContext context, String label, int value) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(label, style: textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _statItem(context, 'Books', _books.length),
            _statItem(context, 'Pages', totalPages(_books)),
            _statItem(context, 'Unread', unread(_books).length),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${_visible.length})')),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildHeader(context),
          ),

          _buildFilters(),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _visible.length,
              itemBuilder: (context, index) {
                final book = _visible[index];

                return BookTile(
                  book: book,
                  onToggle: () {
                    setState(() {
                      book.read = !book.read;
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
