import 'dart:convert';

import 'package:xsd/src/codecs/unsignedByte/config.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `unsignedByte` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class UnsignedByteEncoder extends Converter<String, int> {
  const UnsignedByteEncoder();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    input = processWhiteSpace(input, unsignedByteConstraints.whitespace);

    if (!unsignedByteConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:unsignedByte format');
    }

    final parsedValue = int.parse(input);

    if (parsedValue < unsignedByteConstraints.minInclusive ||
        parsedValue > unsignedByteConstraints.maxInclusive) {
      throw RangeError.range(
        parsedValue,
        unsignedByteConstraints.minInclusive,
        unsignedByteConstraints.maxInclusive,
      );
    }

    return parsedValue;
  }
}
