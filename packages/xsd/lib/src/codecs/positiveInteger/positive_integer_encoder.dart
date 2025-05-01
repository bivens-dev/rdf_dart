import 'dart:convert';

import 'package:xsd/src/codecs/positiveInteger/config.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `positiveInteger` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class PositiveIntegerEncoder extends Converter<String, int> {
  const PositiveIntegerEncoder();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    input = processWhiteSpace(input, positiveIntegerConstraints.whitespace);

    if (!positiveIntegerConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:positiveInteger format');
    }

    final parsedValue = int.parse(input);

    if (parsedValue < positiveIntegerConstraints.minInclusive) {
      throw RangeError.value(parsedValue, null, 'must be a positive number');
    }

    return parsedValue;
  }
}
