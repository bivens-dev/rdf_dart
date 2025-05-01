import 'dart:convert';

import 'package:xsd/src/codecs/negativeInteger/config.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `negativeInteger` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class NegativeIntegerEncoder extends Converter<String, int> {
  const NegativeIntegerEncoder();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    input = processWhiteSpace(input, negativeIntegerConstraints.whitespace);

    if (!negativeIntegerConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:negativeInteger format');
    }

    final parsedValue = int.parse(input);

    if (parsedValue > negativeIntegerConstraints.maxInclusive) {
      throw RangeError.value(parsedValue, null, 'must be a negative number');
    }

    return parsedValue;
  }
}
