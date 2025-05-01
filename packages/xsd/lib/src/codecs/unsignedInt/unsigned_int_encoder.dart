import 'dart:convert';

import 'package:xsd/src/codecs/unsignedInt/config.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `unsignedInt` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class UnsignedIntEncoder extends Converter<String, int> {
  const UnsignedIntEncoder();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    input = processWhiteSpace(input, unsignedIntConstraints.whitespace);

    if (!unsignedIntConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:unsignedInt format');
    }

    final parsedValue = int.parse(input);

    if (parsedValue < unsignedIntConstraints.minInclusive ||
        parsedValue > unsignedIntConstraints.maxInclusive) {
      throw RangeError.range(
        parsedValue,
        unsignedIntConstraints.minInclusive,
        unsignedIntConstraints.maxInclusive,
      );
    }

    return parsedValue;
  }
}
