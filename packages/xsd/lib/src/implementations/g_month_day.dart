import 'package:meta/meta.dart';

/// Represents an XML Schema `xsd:gMonthDay` value (e.g., "--03-15").
///
/// Represents a recurring day and month combination in any year.
/// Includes an optional timezone offset.
///
/// See: https://www.w3.org/TR/xmlschema11-2/#gMonthDay
@immutable
class XsdGMonthDay implements Comparable<XsdGMonthDay> {
  /// A integer representing the month (i.e. 1-12)
  final int month;

  /// A integer representing the day of the month (i.e. 1-31)
  /// Note: XSD doesn't strictly validate day based on month here
  final int day;

  /// The timezone offset from UTC. null means unspecified.
  final Duration? timeZoneOffset;

  /// Creates an [XsdGMonthDay] instance.
  ///
  /// Throws [ArgumentError] if month or day are out of range.
  XsdGMonthDay({required this.month, required this.day, this.timeZoneOffset}) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'Must be between 1 and 12');
    }
    // XSD gMonthDay allows days 29, 30, 31 even for month 02.
    // Validation against a specific year context happens elsewhere if needed.
    if (day < 1 || day > 31) {
      throw ArgumentError.value(day, 'day', 'Must be between 1 and 31');
    }
    // Optional: Add same timezone offset validation as in XsdTime
    if (timeZoneOffset != null) {
      if (timeZoneOffset!.inSeconds.abs() % 60 != 0) {
        throw ArgumentError.value(
          timeZoneOffset,
          'timeZoneOffset',
          'Offset must be a whole number of minutes.',
        );
      }
      if (timeZoneOffset!.inHours.abs() > 14) {
        print(
          'Warning: Timezone offset $timeZoneOffset might be outside the typical XSD range (-14:00 to +14:00).',
        );
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XsdGMonthDay &&
        month == other.month &&
        day == other.day &&
        timeZoneOffset == other.timeZoneOffset;
  }

  @override
  int get hashCode => Object.hash(month, day, timeZoneOffset);

  // Calculates a comparable integer value representing the point in time,
  // normalized to UTC milliseconds relative to a reference leap year epoch.
  // Returns null if timeZoneOffset is null.
  int? get _normalizedUtcMillis {
    if (timeZoneOffset == null) return null;

    // Use a reference leap year (like 2000) to handle Feb 29 correctly.
    // Note: DateTime constructor validates day based on month/year.
    // Since XSD gMonthDay allows "--02-29" lexically, we might need care
    // if we want to represent that concept even outside a leap year context.
    // However, for comparison purposes assuming a leap year context is reasonable.
    const refYear = 2000; // A known leap year

    // Create a DateTime at the beginning of the day in the local timezone.
    // Handle potential invalid date like Feb 30 by clamping or throwing?
    // Let's assume valid month/day pairs for now as per constructor.
    // The XSD constructor allows days 1-31, DateTime might throw for e.g. Feb 30.
    // Consider adding validation here or relying on constructor.
    // For Feb 29, using a leap year like 2000 works.
    try {
      final localDateTime = DateTime.utc(
        refYear,
        month,
        day,
      ); // Treat as UTC initially

      // Calculate milliseconds since epoch for this local date/time
      final localMillis = localDateTime.millisecondsSinceEpoch;

      // Adjust by the timezone offset to get the UTC equivalent milliseconds
      final utcMillis = localMillis - timeZoneOffset!.inMilliseconds;

      return utcMillis;
      // Catching an ArgumentError to throw a StateError makes sense here
      // ignore: avoid_catching_errors
    } on ArgumentError {
      // This might occur if day is invalid for the month (e.g., Feb 30)
      // which the XSD constructor allows but DateTime doesn't.
      // How should comparison handle lexically valid but calendrically invalid dates?
      // Option 1: Throw?
      // Option 2: Return a value that sorts predictably (e.g., always last?)
      // Let's throw for now, assuming comparison is only meaningful for valid dates.
      throw StateError(
        'Cannot compare potentially invalid date: month=$month, day=$day',
      );
    }
  }

  /// Formats the timezone offset (Z, +hh:mm, -hh:mm, or empty).
  /// (Could reuse logic from XsdTime or place in a shared helper)
  String _formatTimeZone() {
    if (timeZoneOffset == null) return '';
    if (timeZoneOffset == Duration.zero) return 'Z';

    final duration = timeZoneOffset;
    final isNegative = duration!.isNegative;
    final absDuration = isNegative ? -duration : duration;
    final totalMinutes = absDuration.inMinutes;
    final tzHour = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final tzMinute = (totalMinutes % 60).toString().padLeft(2, '0');
    final sign = isNegative ? '-' : '+';
    return '$sign$tzHour:$tzMinute';
  }

  /// Returns the canonical string representation (e.g., "--03-15Z").
  @override
  String toString() {
    final mm = month.toString().padLeft(2, '0');
    final dd = day.toString().padLeft(2, '0');
    return '--$mm-$dd${_formatTimeZone()}';
  }

  @override
  int compareTo(XsdGMonthDay other) {
    final thisNorm = _normalizedUtcMillis;
    final otherNorm = other._normalizedUtcMillis;

    // Case 1: Both have timezones
    if (thisNorm != null && otherNorm != null) {
      return thisNorm.compareTo(otherNorm);
    }

    // Case 2: Neither has timezone
    if (thisNorm == null && otherNorm == null) {
      final monthCompare = month.compareTo(other.month);
      if (monthCompare != 0) {
        return monthCompare;
      }
      return day.compareTo(other.day);
    }

    // Case 3: One has timezone, one doesn't - Indeterminate
    // The specification says the result is indeterminate.
    // Dart's compareTo should return -1, 0, or 1. Throwing an error
    // might be more explicit about the indeterminate nature.
    // Or, consistently order those with timezones before/after those without.
    // Let's choose to order timezone-less values before timezone values.
    if (thisNorm == null && otherNorm != null) {
      return -1; // this (no TZ) < other (TZ)
    }
    if (thisNorm != null && otherNorm == null) {
      return 1; // this (TZ) > other (no TZ)
    }

    // Should not happen given the checks above, but satisfies the compiler
    return 0;
  }
}
