import 'dart:convert';

import 'package:xsd/src/implementations/date.dart';

/// Decoder: Converts an [Date] object into its canonical XSD date
/// lexical string representation.
///
/// Relies on the [XsdDate.toString()] method for the formatting.
class XsdDateDecoder extends Converter<Date, String> {
  const XsdDateDecoder();

  /// Converts the [Date] `input` into its canonical string format.
  @override
  String convert(Date input) {
    // Relies on the XsdDate.toString() method for canonical formatting
    return input.toString();
  }
}