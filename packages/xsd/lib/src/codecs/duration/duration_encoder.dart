import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:xsd/src/codecs/duration/config.dart';
import 'package:xsd/src/codecs/duration/duration_codec.dart';
import 'package:xsd/src/helpers/whitespace.dart';
import 'package:xsd/src/implementations/duration.dart';

/// A [Converter] for working with XML Schema `duration` data
class DurationEncoder extends Converter<String, XSDDuration> {
  const DurationEncoder();

  @override
  XSDDuration convert(String input) => _convert(input);

  XSDDuration _convert(String input) {
    input = processWhiteSpace(input, durationConstraints.whitespace);

    if (!DurationCodec.matchesLexicalSpace(input)) {
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