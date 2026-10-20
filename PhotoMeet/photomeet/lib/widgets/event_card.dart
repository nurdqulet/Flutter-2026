import 'package:flutter/material.dart';

import '../models/photo_event.dart';
import '../utils/format.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onFavourite,
    this.onTap,
  });

  final PhotoEvent event;
  final VoidCallback onFavourite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final date = event.when;
    final (:taken, :free) = event.places;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 68,
                height: 72,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: scheme.surfaceContainerHighest,
                        child: Icon(
                          event.category.icon,
                          color: event.category.color(scheme),
                        ),
                      ),
                    ),
                    if (event.isFull || free <= 5)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: event.isFull
                                ? scheme.errorContainer
                                : scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event.isFull ? 'FULL' : '$free left',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: event.isFull
                                  ? scheme.onErrorContainer
                                  : scheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    if (date != null)
                      Text(
                        formatDateTime(date),
                        style: theme.textTheme.bodySmall,
                      ),
                    Text(
                      event.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$taken / ${event.limit} registered',
                      style: theme.textTheme.labelSmall,
                    ),
                    if (event.isPast)
                      Text(
                        'Past event',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.error,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: event.favourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onFavourite,
                icon: Icon(
                  event.favourite ? Icons.favorite : Icons.favorite_border,
                ),
                color: event.favourite ? scheme.primary : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
