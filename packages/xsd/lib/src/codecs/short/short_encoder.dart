import 'dart:convert';

import 'package:xsd/src/codecs/short/config.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `short` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class ShortEncoder extends Converter<String, int> {
  const ShortEncoder();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    input = processWhiteSpace(input, shortConstraints.whitespace);

    if (!shortConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:short format');
    }

    final parsedValue = int.parse(input);

    if (parsedValue < shortConstraints.minInclusive ||
        parsedValue > shortConstraints.maxInclusive) {
      throw RangeError.range(
        parsedValue,
        shortConstraints.minInclusive,
        shortConstraints.maxInclusive,
      );
    }

    return parsedValue;
  }
}