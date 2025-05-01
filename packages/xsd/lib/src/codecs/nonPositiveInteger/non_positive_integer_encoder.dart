import 'dart:convert';

import 'package:xsd/src/codecs/nonPositiveInteger/config.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `nonPositiveInteger` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class NonPositiveIntegerEncoder extends Converter<String, int> {
  const NonPositiveIntegerEncoder();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    input = processWhiteSpace(
      input,
      nonPositiveIntegerConstraints.whitespace,
    );

    if (!nonPositiveIntegerConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:nonPositiveInteger format');
    }

    final parsedValue = int.parse(input);

    if (parsedValue > nonPositiveIntegerConstraints.maxInclusive) {
      throw RangeError.value(
        parsedValue,
        null,
        'must be less than ${nonPositiveIntegerConstraints.maxInclusive}',
      );
    }

    return parsedValue;
  }
}