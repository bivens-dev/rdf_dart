import 'dart:convert';

import 'package:xsd/src/codecs/gMonthDay/config.dart';
import 'package:xsd/src/codecs/gMonthDay/g_month_day_codec.dart.dart';
import 'package:xsd/src/helpers/whitespace.dart';
import 'package:xsd/src/implementations/g_month_day.dart';

/// Encoder: String -> XsdGMonthDay
class XsdGMonthDayEncoder extends Converter<String, XsdGMonthDay> {
  const XsdGMonthDayEncoder();

  @override
  XsdGMonthDay convert(String input) {
    final processedInput = processWhiteSpace(
      input,
      gMonthDayconstraints.whitespace,
    );
    final match = gMonthDayRegex.firstMatch(processedInput);

    if (match == null) {
      throw FormatException('Invalid xsd:gMonthDay format: "$input"');
    }

    try {
      final month = int.parse(match.group(1)!);
      final day = int.parse(match.group(2)!);
      final timeZoneOffset = XsdGMonthDayCodec.parseTimeZone(match, 3, 4, 5, 6);

      // Constructor validates ranges
      return XsdGMonthDay(
        month: month,
        day: day,
        timeZoneOffset: timeZoneOffset,
      );
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('Error parsing xsd:gMonthDay "$input": $e');
    }
  }
}