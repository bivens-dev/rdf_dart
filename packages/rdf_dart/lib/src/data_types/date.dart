import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rdf_dart/src/data_types/helper.dart';

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
    if (identical(this, other)) return true;
    return other is XsdDate &&
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

// --- Codec Implementation ---

/// The canonical instance of [XsdDateCodec].
const xsdDateCodec = XsdDateCodec._();

/// A [Codec] for working with XML Schema `xsd:date` lexical values.
///
/// Encodes lexical strings into [XsdDate] objects and decodes [XsdDate]
/// objects into their canonical lexical string representation.
class XsdDateCodec extends Codec<String, XsdDate> {
  final Converter<String, XsdDate> _encoder;
  final Converter<XsdDate, String> _decoder;

  const XsdDateCodec._()
    // ignore: avoid_field_initializers_in_const_classes
    : _decoder = const XsdDateDecoder._(),
      // ignore: avoid_field_initializers_in_const_classes
      _encoder = const XsdDateEncoder._();

  @override
  Converter<XsdDate, String> get decoder => _decoder;

  @override
  Converter<String, XsdDate> get encoder => _encoder;

  /// Defines constraints and patterns related to the `xsd:date` datatype.
  static final constraints = (
    /// Whitespace processing rule for `xsd:date`.
    whitespace: Whitespace.collapse,

    /// Original regex from the XSD 1.1 specification for validation.
    lexicalSpace: RegExp(
      r'^(-?(?:[1-9][0-9]{3,}|0[0-9]{3}))-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])(Z|([+-])([01][0-9]|1[0-3]):([0-5][0-9])|14:00)?$',
    ),

    /// Refined regex used for parsing, making the optional timezone group capturing
    /// and adjusting sub-group indices for easier extraction in [parseTimeZone].
    refinedRegex: RegExp(
      // Year part (Group 1)
      '^(-?(?:[1-9][0-9]{3,}|0[0-9]{3}))'
      '-'
      // Month part (Group 2)
      '(0[1-9]|1[0-2])'
      '-'
      // Day part (Group 3)
      '(0[1-9]|[12][0-9]|3[01])'
      // Start Capturing Group 4 (Optional Full Timezone)
      '('
      // Z alternative (Group 5)
      '(Z)'
      '|'
      // Offset < 14h alternative (Groups 6, 7, 8)
      '([+-])(0[0-9]|1[0-3]):([0-5][0-9])'
      '|'
      // Offset = 14h alternative (Groups 9, 10)
      '([+-])(14):00'
      r')?$', // End Group 4 and Anchor
    ),
  );

  /// Parses the timezone portion of a matched `xsd:date` string.
  ///
  /// Expects a [Match] object obtained from matching [constraints.refinedRegex].
  /// Uses capture groups 5 through 10 to determine the timezone offset.
  /// Returns `Duration.zero` for 'Z', a [Duration] for +hh:mm/-hh:mm offsets,
  /// or `null` if no timezone is present in the match.
  static Duration? parseTimeZone(Match match) {
    if (match.group(5) != null) {
      // Check Group 5 (Z)
      return Duration.zero;
    } else if (match.group(6) != null) {
      // Check Group 6 (Sign <14h)
      final sign = match.group(6)!;
      final tzHour = int.parse(match.group(7)!); // Use Group 7 (hh <14)
      final tzMinute = int.parse(match.group(8)!); // Use Group 8 (mm)
      var offset = Duration(hours: tzHour, minutes: tzMinute);
      if (sign == '-') {
        offset = -offset;
      }
      return offset;
    } else if (match.group(9) != null) {
      // Check Group 9 (Sign 14h)
      final sign = match.group(9)!;
      // Group 10 is '14'
      var offset = Duration(hours: 14);
      if (sign == '-') {
        offset = -offset;
      }
      return offset;
    }
    return null; // No timezone specified
  }
}

/// Encoder: Converts an XSD date lexical string into an [XsdDate] object.
///
/// Parses strings conforming to the `xsd:date` lexical format:
/// `CCYY-MM-DD(Z|(+|-)hh:mm)?`
/// Throws [FormatException] if the input string is not a valid lexical
/// representation or if the date components are invalid (e.g., invalid day
/// for month/year, year 0).
class XsdDateEncoder extends Converter<String, XsdDate> {
  const XsdDateEncoder._();

  @override
  XsdDate convert(String input) {
    // Process whitespace according to XSD rules
    final processedInput = processWhiteSpace(
      input,
      XsdDateCodec.constraints.whitespace,
    );

    // Use the refined regex to match and extract components
    final match = XsdDateCodec.constraints.refinedRegex.firstMatch(
      processedInput,
    );

    // If the regex doesn't match the expected format, throw an error
    if (match == null) {
      throw FormatException('Invalid xsd:date format: "$input"');
    }

    try {
      // Extract year, month, and day strings from regex groups
      final yearString = match.group(1)!;
      final monthString = match.group(2)!;
      final dayString = match.group(3)!;

      // Parse numeric components
      final year = int.parse(yearString);
      final month = int.parse(monthString);
      final day = int.parse(dayString);

      // Parse the optional timezone using the static helper
      final timeZoneOffset = XsdDateCodec.parseTimeZone(match);

      // Create the XsdDate object; the constructor handles final validation
      return XsdDate(
        year: year,
        month: month,
        day: day,
        timeZoneOffset: timeZoneOffset,
      );
      // Catch validation errors from the XsdDate constructor
      // (e.g., day invalid for month/year, year 0, invalid timezone range)
      // ignore: avoid_catching_errors
    } on ArgumentError catch (e) {
      // Re-throw as FormatException for consistency within the converter
      throw FormatException(
        'Invalid date components for "$input": ${e.message}',
      );
    } on FormatException catch (e) {
      // Catch potential int.parse errors
      throw FormatException('Invalid number format in "$input": $e');
    } catch (e) {
      // Catch any other unexpected errors during parsing
      throw FormatException('Error parsing xsd:date "$input": $e');
    }
  }
}

/// Decoder: Converts an [XsdDate] object into its canonical XSD date
/// lexical string representation.
///
/// Relies on the [XsdDate.toString()] method for the formatting.
class XsdDateDecoder extends Converter<XsdDate, String> {
  const XsdDateDecoder._();

  /// Converts the [XsdDate] `input` into its canonical string format.
  @override
  String convert(XsdDate input) {
    // Relies on the XsdDate.toString() method for canonical formatting
    return input.toString();
  }
}
