import 'package:meta/meta.dart';

/// Represents an XML Schema `xsd:date` value (e.g., "2023-03-26Z").
///
/// Represents a specific Gregorian date with an optional timezone.
/// Corresponds to the entire day specified.
///
/// See: https://www.w3.org/TR/xmlschema11-2/#date
@immutable
class XsdDate implements Comparable<XsdDate> {
  /// The Gregorian year. Can be negative. Must not be 0.
  final int year;

  /// The month (1-12).
  final int month;

  /// The day (1-31), validated according to month and year.
  final int day;

  /// The timezone offset from UTC. null means unspecified.
  final Duration? timeZoneOffset;

  /// Creates an [XsdDate] instance.
  ///
  /// Throws [ArgumentError] if year is 0, month/day are out of range
  /// for the given year, or timezone offset is invalid.
  XsdDate({
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

    // 3. Validate day using DateTime.utc (handles month/day range and leap years)
    try {
      // Using UTC ensures consistency regardless of local system time.
      DateTime.utc(year, month, day);
      // Re-throw with a more specific message.
      // ignore: avoid_catching_errors
    } on ArgumentError catch (e) {
      throw ArgumentError(
        'Invalid day ($day) for month $month in year $year: ${e.message}',
      );
    }

    // 4. Validate timeZoneOffset (if present)
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
      // Adjust by the timezone offset to find the actual UTC instant when this date started
      final actualStartInstantMillis =
          startMillisUtc - timeZoneOffset!.inMilliseconds;
      return actualStartInstantMillis;
      // Catching ArgumentError which might theoretically happen if constructor validation failed somehow
      // ignore: avoid_catching_errors
    } on ArgumentError {
      // Should ideally be prevented by constructor validation
      throw StateError(
        'Cannot normalize invalid date: year=$year, month=$month, day=$day',
      );
    }
  }

  @override
  int compareTo(XsdDate other) {
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
    // --- Implementation Needed ---
    // Check type and compare year, month, day, timeZoneOffset.
    // --- ---
    if (identical(this, other)) return true;
    throw UnimplementedError('operator == not implemented');
  }

  @override
  int get hashCode {
    // --- Implementation Needed ---
    // Use Object.hash(year, month, day, timeZoneOffset).
    // --- ---
    throw UnimplementedError('hashCode not implemented');
  }

  /// Formats the timezone offset (Z, +hh:mm, -hh:mm, or empty).
  /// (Can reuse logic from XsdGMonthDay or place in a shared helper)
  String _formatTimeZone() {
    // --- Implementation Needed (or reuse/import helper) ---
    if (timeZoneOffset == null) return '';
    if (timeZoneOffset == Duration.zero) return 'Z';
    // ... formatting logic for +hh:mm / -hh:mm ...
    // --- ---
    throw UnimplementedError('_formatTimeZone not implemented');
  }

  /// Returns the canonical XSD string representation (e.g., "2023-03-26Z", "-0045-01-20").
  @override
  String toString() {
    // --- Implementation Needed ---
    // 1. Format year: Use abs().padLeft(4, '0'). Prepend '-' if negative.
    // 2. Format month: padLeft(2, '0').
    // 3. Format day: padLeft(2, '0').
    // 4. Append result of _formatTimeZone().
    // --- ---
    throw UnimplementedError('toString not implemented');
  }
}
