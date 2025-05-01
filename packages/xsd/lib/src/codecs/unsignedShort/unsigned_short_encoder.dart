import 'dart:convert';

import 'package:xsd/src/codecs/unsignedShort/config.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `unsignedShort` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class UnsignedShortEncoder extends Converter<String, int> {
  const UnsignedShortEncoder();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    input = processWhiteSpace(input, unsignedShortConstraints.whitespace);

    if (!unsignedShortConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid format');
    }

    final parsedValue = int.parse(input);

    if (parsedValue < unsignedShortConstraints.minInclusive ||
        parsedValue > unsignedShortConstraints.maxInclusive) {
      throw RangeError.range(
        parsedValue,
        unsignedShortConstraints.minInclusive,
        unsignedShortConstraints.maxInclusive,
      );
    }

    return parsedValue;
  }
}
