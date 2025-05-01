import 'dart:convert';

import 'package:xsd/src/codecs/integer/config.dart';

import '../../helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `integer` data
/// It uses Dart's built in [BigInt.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class IntegerEncoder extends Converter<String, BigInt> {
  const IntegerEncoder();

  @override
  BigInt convert(String input) => _convert(input);

  BigInt _convert(String input) {
    input = processWhiteSpace(input, integerConstraints.whitespace);
    if (!integerConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:integer format');
    }

    final parsedValue = BigInt.parse(input);

    return parsedValue;
  }
}
