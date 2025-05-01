import 'dart:convert';

import 'package:xsd/src/codecs/gMonthDay/g_month_day_decoder.dart';
import 'package:xsd/src/codecs/gMonthDay/g_month_day_encoder.dart';
import 'package:xsd/src/implementations/g_month_day.dart';

/// The canonical instance of [XsdGMonthDayCodec].
const xsdGMonthDayCodec = XsdGMonthDayCodec._();

/// A [Codec] for working with XML Schema `gMonthDay` data.
class XsdGMonthDayCodec extends Codec<String, XsdGMonthDay> {
  const XsdGMonthDayCodec._();

  @override
  Converter<XsdGMonthDay, String> get decoder => const XsdGMonthDayDecoder();

  @override
  Converter<String, XsdGMonthDay> get encoder => const XsdGMonthDayEncoder();

  /// Parses timezone groups from a regex match.
  /// Assumes groups align with: groupZ, groupSign, groupHour, groupMinute
  /// (Could be moved to a shared helper)
  static Duration? parseTimeZone(
    Match match,
    int groupZ,
    int groupSign,
    int groupHour,
    int groupMinute,
  ) {
    if (match.group(groupZ) != null) {
      return Duration.zero; // 'Z'
    } else if (match.group(groupSign) != null) {
      final sign = match.group(groupSign)!;
      final tzHour = int.parse(match.group(groupHour)!);
      final tzMinute = int.parse(match.group(groupMinute)!);

      if (tzHour < 0 ||
          tzHour > 14 ||
          tzMinute < 0 ||
          tzMinute > 59 ||
          (tzHour == 14 && tzMinute != 0)) {
        throw FormatException('Invalid timezone offset hours/minutes');
      }

      var offset = Duration(hours: tzHour, minutes: tzMinute);
      if (sign == '-') {
        offset = -offset;
      }
      return offset;
    }
    return null; // No timezone specified
  }
}
