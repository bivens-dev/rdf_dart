import 'dart:convert';

import 'package:xsd/src/codecs/short/config.dart';

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `short` data type.
class ShortDecoder extends Converter<int, String> {
  const ShortDecoder();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < shortConstraints.minInclusive ||
        input > shortConstraints.maxInclusive) {
      throw RangeError.range(
        input,
        shortConstraints.minInclusive,
        shortConstraints.maxInclusive,
      );
    }

    return input.toString();
  }
}