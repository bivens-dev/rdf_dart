import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';

/// A class which represents a duration in terms of its constituent components.
///
/// The xsd:duration type is unusual in that it has a partial order,
/// therefore it is not possible to extend Comparable. This class
/// represents the individual components of a duration (years, months,
/// days, hours, minutes, seconds).
@immutable
class XSDDuration {
  /// The number of years in the duration, or null if not specified.
  final int? years;

  /// The number of months in the duration, or null if not specified.
  final int? months;

  /// The number of days in the duration, or null if not specified.
  final int? days;

  /// The number of hours in the duration, or null if not specified.
  final int? hours;

  /// The number of minutes in the duration, or null if not specified.
  final int? minutes;

  /// The number of seconds (and fractional seconds) in the duration,
  /// or null if not specified.
  final Decimal? seconds;

  /// Creates a [XSDDuration] instance.
  ///
  /// All parameters are optional.  A null value for a parameter indicates
  /// that the corresponding component is not present in the duration.
  const XSDDuration({
    this.years,
    this.months,
    this.days,
    this.hours,
    this.minutes,
    this.seconds,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    // The xsd:duration type has a partial order, so equality check are only
    // conclusive if all components are equal
    if (other is XSDDuration) {
      return years == other.years &&
          months == other.months &&
          days == other.days &&
          hours == other.hours &&
          minutes == other.minutes &&
          seconds == other.seconds;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(years, months, days, hours, minutes, seconds);

  @override
  String toString() {
    // The following rules apply to xsd:duration values:
    //
    // 1. Any of these numbers and corresponding designators may be
    //    absent if they are equal to 0, but at least one number
    //    and designator must appear.
    // 2. The numbers may be any unsigned integer, with the exception of the
    //    number of seconds, which may be an unsigned decimal number.
    // 3. If a decimal point appears in the number of seconds, there must be
    //    at least one digit after the decimal point.
    // 4. A minus sign may appear before the P to specify a negative duration.
    // 5. If no time items (hour, minute, second) are present, the letter
    //    T must not appear.
    //
    // Source: https://www.datypic.com/sc/xsd/t-xsd_duration.html

    final isNegative =
        (years != null && years! < 0) ||
        (months != null && months! < 0) ||
        (days != null && days! < 0) ||
        (hours != null && hours! < 0) ||
        (minutes != null && minutes! < 0) ||
        (seconds != null && seconds! < Decimal.zero);

    final buffer = StringBuffer();

    if (isNegative) {
      buffer.write('-');
    }

    buffer.write('P');

    if (years != null && years != 0) {
      buffer.write('${years!.abs()}Y');
    }
    if (months != null && months != 0) {
      buffer.write('${months!.abs()}M');
    }
    if (days != null && days != 0) {
      buffer.write('${days!.abs()}D');
    }

    if ((hours != null && hours != 0) ||
        (minutes != null && minutes != 0) ||
        (seconds != null && seconds != Decimal.zero)) {
      buffer.write('T');
      if (hours != null && hours != 0) {
        buffer.write('${hours!.abs()}H');
      }
      if (minutes != null && minutes != 0) {
        buffer.write('${minutes!.abs()}M');
      }
      if (seconds != null && seconds != Decimal.zero) {
        buffer.write('${seconds!.abs()}S');
      }
    }

    // Handle the edge case of P0D, and PT0S
    if (buffer.toString() == 'P') {
      return 'PT0S'; // The specification has this as the offical format.
    }

    return buffer.toString();
  }
}