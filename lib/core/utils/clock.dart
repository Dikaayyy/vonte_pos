/// Abstraction for clock time to allow predictable time injection in tests.
abstract class Clock {
  const Clock();
  DateTime now();
}

/// Standard system clock using [DateTime.now].
class SystemClock extends Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Settable clock for unit tests.
class TestClock extends Clock {
  DateTime _current;

  TestClock(this._current);

  void setTime(DateTime time) {
    _current = time;
  }

  void advance(Duration duration) {
    _current = _current.add(duration);
  }

  @override
  DateTime now() => _current;
}

