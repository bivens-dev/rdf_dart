import 'dart:convert';

import 'package:xsd/src/codecs/long/config.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `long` data
/// It uses Dart's built in [BigInt.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class LongEncoder extends Converter<String, BigInt> {
  const LongEncoder();

  @override
  BigInt convert(String input) => _convert(input);

  BigInt _convert(String input) {
    input = processWhiteSpace(input, longConstraints.whitespace);

    if (!longConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:long format');
    }

    final parsedValue = BigInt.parse(input);

    if (parsedValue < longConstraints.minInclusive ||
        parsedValue > longConstraints.maxInclusive) {
      throw RangeError(
        'xsd:long values must be between ${longConstraints.minInclusive} and ${longConstraints.maxInclusive}',
      );
    }

    return parsedValue;
  }
}