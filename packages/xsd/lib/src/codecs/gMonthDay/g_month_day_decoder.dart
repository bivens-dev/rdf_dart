import 'dart:convert';

import 'package:xsd/src/implementations/g_month_day.dart';

/// Decoder: XsdGMonthDay -> String
class XsdGMonthDayDecoder extends Converter<XsdGMonthDay, String> {
  const XsdGMonthDayDecoder();

  @override
  String convert(XsdGMonthDay input) {
    return input.toString();
  }
}