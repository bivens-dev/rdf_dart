import 'dart:convert';

import 'package:xsd/src/codecs/date/date_decoder.dart';
import 'package:xsd/src/codecs/date/date_encoder.dart';
import 'package:xsd/src/implementations/date.dart';

/// The canonical instance of [XsdDateCodec].
const xsdDateCodec = XsdDateCodec._();

/// A [Codec] for working with XML Schema `xsd:date` lexical values.
///
/// Encodes lexical strings into [Date] objects and decodes [Date]
/// objects into their canonical lexical string representation.
class XsdDateCodec extends Codec<String, Date> {
  const XsdDateCodec._();

  @override
  Converter<Date, String> get decoder => const XsdDateDecoder();

  @override
  Converter<String, Date> get encoder => XsdDateEncoder();

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
