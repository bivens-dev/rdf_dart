import 'package:meta/meta.dart';

/// Represents an XML Schema `xsd:date` value (e.g., "2023-03-26Z").
///
/// Represents a specific Gregorian date with an optional timezone.
/// Corresponds to the entire day specified.
///
/// See: https://www.w3.org/TR/xmlschema11-2/#date
@immutable
class Date implements Comparable<Date> {
  /// The Gregorian year. Can be negative. Must not be 0.
  final int year;

  /// The month (1-12).
  final int month;

  /// The day (1-31), validated according to month and year.
  final int day;

  /// The timezone offset from UTC. null means unspecified.
  final Duration? timeZoneOffset;

  /// Creates an [Date] instance.
  ///
  /// Throws [ArgumentError] if year is 0, month/day are out of range
  /// for the given year, or timezone offset is invalid.
  Date({
    required this.year,
    required this.month,
    required this.day,
    this.timeZoneOffset,
  }) {
    // 1. Validate year
    if (year == 0) {
      throw ArgumentError.value(year, 'year', 'Year must not be 0');
    }

    // 2. Validate month (implicitly handled by DateTime.utc below)
    if (month < 1 || month > 12) {
      throw ArgumentError.value(
        month,
        'month',
        'Month must be between 1 and 12',
      );
    }

    // 3. Validate day (basic range check first, then check validity for month/year)
    if (day < 1 || day > 31) {
      throw ArgumentError.value(day, 'day', 'Day must be between 1 and 31');
    }

    // 4. Validate day using DateTime.utc (handles month/day range and leap years)
    try {
      // Using UTC ensures consistency regardless of local system time.
      final validationDate = DateTime.utc(year, month, day);
      // Check if DateTime adjusted the day or month (indicating invalid input day)
      if (validationDate.day != day ||
          validationDate.month != month ||
          validationDate.year != year) {
        throw ArgumentError(
          'Day ($day) is invalid for month $month in year $year',
        );
      }
      // Re-throw with a more specific message.
      // ignore: avoid_catching_errors
    } on ArgumentError {
      throw ArgumentError(
        'Invalid date components: year=$year, month=$month, day=$day',
      );
    }

    // 5. Validate timeZoneOffset (if present)
    if (timeZoneOffset != null) {
      // Must be whole minutes
      if (timeZoneOffset!.inSeconds.abs() % 60 != 0) {
        throw ArgumentError.value(
          timeZoneOffset,
          'timeZoneOffset',
          'Offset must be a whole number of minutes.',
        );
      }
      // Must be within +/- 14:00 range
      // Note: XSD spec allows -14:00 to +14:00 *inclusive*.
      // Duration.inHours rounds towards zero, so check minutes directly.
      final totalMinutes = timeZoneOffset!.inMinutes;
      if (totalMinutes < -14 * 60 || totalMinutes > 14 * 60) {
        throw ArgumentError.value(
          timeZoneOffset,
          'timeZoneOffset',
          'Offset must be between -14:00 and +14:00 inclusive.',
        );
      }
    }
  }

  /// Calculates a comparable integer value representing the start instant
  /// of this date, normalized to UTC milliseconds relative to epoch.
  /// Returns null if timeZoneOffset is null.
  int? get _normalizedStartMillis {
    if (timeZoneOffset == null) return null;

    try {
      // Get the DateTime representing the start of the day in UTC
      final startOfDayUtc = DateTime.utc(year, month, day);
      // Get milliseconds since epoch for this UTC start time
      final startMillisUtc = startOfDayUtc.millisecondsSinceEpoch;
      // Adjust by the timezone offset to find the actual UTC instant
      // when this date started
      final actualStartInstantMillis =
          startMillisUtc - timeZoneOffset!.inMilliseconds;
      return actualStartInstantMillis;
      // Catching ArgumentError which might theoretically happen if
      // constructor validation failed somehow
      // ignore: avoid_catching_errors
    } on ArgumentError {
      // Should ideally be prevented by constructor validation
      throw StateError(
        'Cannot normalize invalid date: year=$year, month=$month, day=$day',
      );
    }
  }

  @override
  int compareTo(Date other) {
    final thisNorm = _normalizedStartMillis;
    final otherNorm = other._normalizedStartMillis;

    // Case 1: Both have timezones
    if (thisNorm != null && otherNorm != null) {
      return thisNorm.compareTo(otherNorm);
    }

    // Case 2: Neither has timezone
    if (thisNorm == null && otherNorm == null) {
      final yearCompare = year.compareTo(other.year);
      if (yearCompare != 0) return yearCompare;
      final monthCompare = month.compareTo(other.month);
      if (monthCompare != 0) return monthCompare;
      return day.compareTo(other.day);
    }

    // Case 3: One has timezone, one doesn't - Indeterminate
    // Following convention: timezone-less < timezone'd
    if (thisNorm == null && otherNorm != null) {
      return -1; // this (no TZ) < other (TZ)
    }
    // This is the remaining case: thisNorm != null && otherNorm == null
    return 1; // this (TZ) > other (no TZ)
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Date &&
        other.runtimeType == runtimeType &&
        year == other.year &&
        month == other.month &&
        day == other.day &&
        timeZoneOffset == other.timeZoneOffset;
  }

  @override
  int get hashCode => Object.hash(year, month, day, timeZoneOffset);

  /// Formats the timezone offset (Z, +hh:mm, -hh:mm, or empty).
  String _formatTimeZone() {
    if (timeZoneOffset == null) return '';
    if (timeZoneOffset == Duration.zero) return 'Z';

    final duration = timeZoneOffset!; // Known non-null here
    final isNegative = duration.isNegative;
    final absDuration = isNegative ? -duration : duration;
    final totalMinutes = absDuration.inMinutes;
    final tzHour = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final tzMinute = (totalMinutes % 60).toString().padLeft(2, '0');
    final sign = isNegative ? '-' : '+';
    return '$sign$tzHour:$tzMinute';
  }

  /// Returns the canonical XSD string representation (e.g., "2023-03-26Z", "-0045-01-20").
  @override
  String toString() {
    // Format year: Pad absolute value to at least 4 digits, prepend '-' if negative
    final String yearString;
    if (year < 0) {
      // Need 4 digits *after* the sign for negative years, e.g., -0045
      yearString = '-${year.abs().toString().padLeft(4, '0')}';
    } else {
      // Pad positive years to at least 4 digits
      yearString = year.toString().padLeft(4, '0');
    }

    // Format month and day
    final mm = month.toString().padLeft(2, '0');
    final dd = day.toString().padLeft(2, '0');

    // Combine and append timezone
    return '$yearString-$mm-$dd${_formatTimeZone()}';
  }
}