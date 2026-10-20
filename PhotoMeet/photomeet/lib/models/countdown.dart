sealed class Countdown {
  const Countdown();

  static Countdown from(DateTime? date, DateTime now) {
    if (date == null) {
      return const Ended();
    }

    final difference = date.difference(now);

    if (difference > Duration.zero) {
      return Upcoming(difference);
    }

    final elapsed = now.difference(date);

    if (elapsed < const Duration(hours: 1)) {
      return Started(elapsed);
    }

    return const Ended();
  }
}

class Upcoming extends Countdown {
  const Upcoming(this.remaining);

  final Duration remaining;
}

class Started extends Countdown {
  const Started(this.elapsed);

  final Duration elapsed;
}

class Ended extends Countdown {
  const Ended();
}

String countdownLabel(Countdown countdown) => switch (countdown) {
  Upcoming(:final remaining) => _upcomingLabel(remaining),
  Started() => 'In progress',
  Ended() => 'Ended',
};

String _upcomingLabel(Duration duration) {
  if (duration.inDays > 0) {
    return 'In ${duration.inDays}d ${duration.inHours % 24}h';
  }

  if (duration.inHours > 0) {
    return 'In ${duration.inHours}h ${duration.inMinutes % 60}m';
  }

  if (duration.inMinutes > 0) {
    return 'In ${duration.inMinutes}m';
  }

  return 'Starting soon';
}
