import 'dart:convert';

import 'package:xsd/src/codecs/byte/config.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `byte` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class ByteEncoder extends Converter<String, int> {
  const ByteEncoder();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    input = processWhiteSpace(input, byteConstraints.whitespace);

    if (!byteConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:byte format');
    }

    final parsedValue = int.parse(input);

    if (parsedValue < byteConstraints.minInclusive ||
        parsedValue > byteConstraints.maxInclusive) {
      throw RangeError.range(
        parsedValue,
        byteConstraints.minInclusive,
        byteConstraints.maxInclusive,
      );
    }

    return parsedValue;
  }
}