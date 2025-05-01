import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:xsd/src/codecs/decimal/config.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `decimal` data
class DecimalEncoder extends Converter<String, Decimal> {
  const DecimalEncoder();

  @override
  Decimal convert(String input) => _convert(input);

  Decimal _convert(String input) {
    input = processWhiteSpace(input, decimalConstraints.whitespace);

    if (!decimalConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:decimal format');
    }

    final parsedValue = Decimal.parse(input);

    return parsedValue;
  }
}