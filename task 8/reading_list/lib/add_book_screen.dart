import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _pages.dispose();
    _year.dispose();
    super.dispose();
  }

  void _saveBook() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      pages: int.parse(_pages.text.trim()),
      year: int.tryParse(_year.text.trim()),
    );

    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'New Book',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter book title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                textInputAction: TextInputAction.next,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                validator: (value) {
                  if ((value ?? '').trim().length < 2) {
                    return 'At least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _author,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  hintText: 'Enter author name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Author is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _pages,
                decoration: const InputDecoration(
                  labelText: 'Pages',
                  hintText: 'Enter number of pages',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                validator: (value) {
                  final n = int.tryParse((value ?? '').trim());

                  if (n == null || n <= 0) {
                    return 'A whole number above 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _year,
                decoration: const InputDecoration(
                  labelText: 'Year (optional)',
                  hintText: 'Enter publication year',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                validator: (value) {
                  final text = (value ?? '').trim();

                  if (text.isEmpty) {
                    return null;
                  }

                  final year = int.tryParse(text);

                  if (year == null ||
                      year < 1450 ||
                      year > DateTime.now().year) {
                    return 'Enter a year from 1450 to ${DateTime.now().year}';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _saveBook,
                icon: const Icon(Icons.save),
                label: const Text('Save Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
