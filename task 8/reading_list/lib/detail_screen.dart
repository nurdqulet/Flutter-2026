import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Delete '${book.title}'?"),
          content: const Text('Are you sure you want to delete this book?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    if (confirmed == true) {
      Navigator.of(context).pop(BookAction.delete);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Book Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: textTheme.headlineSmall),
                    const SizedBox(height: 20),

                    Text('Author: ${book.author}', style: textTheme.bodyLarge),
                    const SizedBox(height: 12),

                    Text('Pages: ${book.pages}', style: textTheme.bodyLarge),
                    const SizedBox(height: 12),

                    Text(
                      book.year == null ? 'Year unknown' : 'Year: ${book.year}',
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Status: ${book.read ? "Read" : "Unread"}',
                      style: textTheme.bodyLarge?.copyWith(
                        color: book.read
                            ? colorScheme.primary
                            : colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop(BookAction.toggleRead);
              },
              icon: Icon(
                book.read ? Icons.remove_done : Icons.check_circle_outline,
              ),
              label: Text(book.read ? 'Mark as unread' : 'Mark as read'),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
