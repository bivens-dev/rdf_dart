// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';
import 'package:rdf_dart/src/data_types/helper.dart';

/// The canonical instance of [DurationCodec].
const durationCodec = DurationCodec._();

/// A [Codec] for working with XML Schema `duration` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#byte
class DurationCodec extends Codec<String, XSDDuration> {
  final Converter<String, XSDDuration> _encoder;
  final Converter<XSDDuration, String> _decoder;

  /// Values taken from the specification
  static final constraints = (whitespace: Whitespace.collapse);

  /// A helper function to check if the provided [String] matches the
  /// lexical space as defined in the specification
  static bool _matchesLexicalSpace(String input) {
    final durationRep =
        r'-?P((([0-9]+Y([0-9]+M)?([0-9]+D)?|([0-9]+M)([0-9]+D)?|([0-9]+D))(T(([0-9]+H)([0-9]+M)?([0-9]+(\.[0-9]+)?S)?|([0-9]+M)([0-9]+(\.[0-9]+)?S)?|([0-9]+(\.[0-9]+)?S)))?)|(T(([0-9]+H)([0-9]+M)?([0-9]+(\.[0-9]+)?S)?|([0-9]+M)([0-9]+(\.[0-9]+)?S)?|([0-9]+(\.[0-9]+)?S))))';
    final pattern = '^$durationRep\$';
    final regex = RegExp(pattern, unicode: true);
    return regex.hasMatch(input);
  }

  const DurationCodec._()
    : _decoder = const DurationDecoder._(),
      _encoder = const DurationEncoder._();

  @override
  Converter<XSDDuration, String> get decoder => _decoder;

  @override
  Converter<String, XSDDuration> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `duration` data
class DurationEncoder extends Converter<String, XSDDuration> {
  const DurationEncoder._();

  @override
  XSDDuration convert(String input) => _convert(input);

  XSDDuration _convert(String input) {
    input = processWhiteSpace(input, DurationCodec.constraints.whitespace);

    if (!DurationCodec._matchesLexicalSpace(input)) {
      throw FormatException('invalid xsd:duration format');
    }

    final match = _extractComponents(input);

    try {
      final isNegative = input.startsWith('-');

      // Extract components, handling nulls for missing parts.
      // Note that month and minute both use 'M'
      var years = match.group(1) != null ? int.parse(match.group(1)!) : null;
      var months = match.group(2) != null ? int.parse(match.group(2)!) : null;
      var days = match.group(3) != null ? int.parse(match.group(3)!) : null;
      var hours = match.group(4) != null ? int.parse(match.group(4)!) : null;
      var minutes = match.group(5) != null ? int.parse(match.group(5)!) : null;
      var seconds =
          match.group(6) != null ? Decimal.parse(match.group(6)!) : null;

      // Apply the negative sign to ALL components
      if (isNegative) {
        years = years == null ? null : -years;
        months = months == null ? null : -months;
        days = days == null ? null : -days;
        hours = hours == null ? null : -hours;
        minutes = minutes == null ? null : -minutes;
        seconds = seconds == null ? null : -seconds;
      }
      // The XSD spec requires that if years/months is positive, seconds must be
      // positive, and vice versa.
      if ((years != null && years > 0 || months != null && months > 0) &&
          (seconds != null && seconds.compareTo(Decimal.zero) < 0)) {
        throw FormatException(
          'seconds must not be negative when months is positive in xsd:duration: $input',
        );
      }

      if ((years != null && years < 0 || months != null && months < 0) &&
          (seconds != null && seconds.compareTo(Decimal.zero) > 0)) {
        throw FormatException(
          'seconds must not be positive when months is negative in xsd:duration: $input',
        );
      }

      return XSDDuration(
        years: years,
        months: months,
        days: days,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );
    } on FormatException {
      throw FormatException('Unable to parse xsd:duration: $input');
    }
  }

  RegExpMatch _extractComponents(String lexicalForm) {
    final match = RegExp(
      r'^-?P(?:(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?)$',
    ).firstMatch(lexicalForm);

    if (match == null) {
      throw FormatException('Unable to parse xsd:duration: $lexicalForm');
    }
    return match;
  }
}

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `byte` data type.
class DurationDecoder extends Converter<XSDDuration, String> {
  const DurationDecoder._();

  @override
  String convert(XSDDuration input) => _convert(input);

  String _convert(XSDDuration input) {
    return input.toString();
  }
}

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
