import 'dart:convert';

import 'package:decimal/decimal.dart';

/// A [Converter] for translating from [Decimal] data type back into a
/// [String] that represents a valid XML Schema `decimal` data type.
class DecimalDecoder extends Converter<Decimal, String> {
  const DecimalDecoder();

  @override
  String convert(Decimal input) => _convert(input);

  String _convert(Decimal input) {
    return input.toString();
  }
}