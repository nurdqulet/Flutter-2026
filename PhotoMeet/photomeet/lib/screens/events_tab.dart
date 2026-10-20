import 'package:flutter/material.dart';

import '../models/photo_event.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_card.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({
    super.key,
    required this.events,
    required this.onFavourite,
    required this.emptyMessage,
    this.showFilters = true,
    this.onOpen,
  });

  final List<PhotoEvent> events;
  final ValueChanged<PhotoEvent> onFavourite;
  final String emptyMessage;
  final bool showFilters;
  final ValueChanged<PhotoEvent>? onOpen;

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  EventCategory? _category;
  bool _showPast = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _query = '';
    });
  }

  List<PhotoEvent> _visibleEvents() {
    final query = _query.trim().toLowerCase();

    final result = widget.events.where((event) {
      if (!widget.showFilters) {
        return true;
      }

      final matchesSearch = event.title.toLowerCase().contains(query);
      final matchesCategory = _category == null || event.category == _category;
      final matchesDate = _showPast || !event.isPast;

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();

    result.sort((a, b) {
      if (a.isPast != b.isPast) {
        return a.isPast ? 1 : -1;
      }

      final firstDate = a.when;
      final secondDate = b.when;

      if (firstDate == null) {
        return secondDate == null ? 0 : 1;
      }

      if (secondDate == null) {
        return -1;
      }

      return firstDate.compareTo(secondDate);
    });

    return result;
  }

  Widget _buildCard(PhotoEvent event) {
    final open = widget.onOpen;

    return EventCard(
      key: ValueKey(event.id),
      event: event,
      onFavourite: () => widget.onFavourite(event),
      onTap: open == null ? null : () => open(event),
    );
  }

  Widget _buildResults(List<PhotoEvent> events) {
    if (events.isEmpty) {
      final hasEvents = widget.events.isNotEmpty;

      return EmptyState(
        icon: widget.showFilters ? Icons.search_off : Icons.favorite_border,
        message: hasEvents
            ? 'No events match your filters.'
            : widget.emptyMessage,
        buttonLabel: widget.showFilters && _query.isNotEmpty
            ? 'Clear search'
            : null,
        onPressed: widget.showFilters && _query.isNotEmpty
            ? _clearSearch
            : null,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          final columns = ((constraints.maxWidth - 32 + 12) / (360 + 12))
              .ceil();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 220,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) => _buildCard(events[index]),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: events.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _buildCard(events[index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _visibleEvents();

    return Column(
      children: [
        if (widget.showFilters) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextFormField(
              controller: _searchController,
              focusNode: _searchFocus,
              validator: (_) => null,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Search events',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
              onTapOutside: (_) => _searchFocus.unfocus(),
              onFieldSubmitted: (_) => _searchFocus.unfocus(),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _category == null,
                    onSelected: (_) {
                      setState(() {
                        _category = null;
                      });
                    },
                  ),
                ),
                for (final category in EventCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(category.icon, size: 18),
                      label: Text(category.label),
                      selected: _category == category,
                      onSelected: (_) {
                        setState(() {
                          _category = category;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text('Include past events'),
                selected: _showPast,
                onSelected: (value) {
                  setState(() {
                    _showPast = value;
                  });
                },
              ),
            ),
          ),
        ],
        Expanded(child: _buildResults(events)),
      ],
    );
  }
}
