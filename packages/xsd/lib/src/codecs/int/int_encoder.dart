import 'dart:convert';

import 'package:xsd/src/codecs/int/config.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `int` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class IntEncoder extends Converter<String, int> {
  const IntEncoder();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    input = processWhiteSpace(input, intConstraints.whitespace);

    if (!intConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:int format');
    }

    final parsedValue = int.parse(input);

    if (parsedValue < intConstraints.minInclusive ||
        parsedValue > intConstraints.maxInclusive) {
      throw RangeError.range(
        parsedValue,
        intConstraints.minInclusive,
        intConstraints.maxInclusive,
      );
    }

    return parsedValue;
  }
}
