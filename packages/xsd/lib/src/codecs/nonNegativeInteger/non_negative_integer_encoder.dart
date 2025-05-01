import 'dart:convert';

import 'package:xsd/src/codecs/nonNegativeInteger/config.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `nonNegativeInteger` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class NonNegativeIntegerEncoder extends Converter<String, int> {
  const NonNegativeIntegerEncoder();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    input = processWhiteSpace(input, nonNegativeIntegerConstraints.whitespace);

    if (!nonNegativeIntegerConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:nonNegativeInteger format');
    }

    final parsedValue = int.parse(input);

    if (parsedValue < nonNegativeIntegerConstraints.minInclusive) {
      throw RangeError.value(
        parsedValue,
        null,
        'must be greater than ${nonNegativeIntegerConstraints.minInclusive}',
      );
    }

    return parsedValue;
  }
}
