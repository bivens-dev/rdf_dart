import 'dart:convert';

import 'package:xsd/src/codecs/unsignedLong/config.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `unsignedLong` data
/// It uses Dart's built in [BigInt.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class UnsignedLongEncoder extends Converter<String, BigInt> {
  const UnsignedLongEncoder();

  @override
  BigInt convert(String input) => _convert(input);

  BigInt _convert(String input) {
    input = processWhiteSpace(input, unsignedLongConstraints.whitespace);

    if (!unsignedLongConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:unsignedLong format');
    }

    final parsedValue = BigInt.parse(input);

    if (parsedValue < unsignedLongConstraints.minInclusive ||
        parsedValue > unsignedLongConstraints.maxInclusive) {
      throw RangeError(
        'xsd:unsignedLong values must be between ${unsignedLongConstraints.minInclusive} and ${unsignedLongConstraints.maxInclusive}',
      );
    }

    return parsedValue;
  }
}