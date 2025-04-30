import 'dart:convert';

import 'package:xsd/src/codecs/int/config.dart';

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `int` data type.
class IntDecoder extends Converter<int, String> {
  const IntDecoder();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < intConstraints.minInclusive ||
        input > intConstraints.maxInclusive) {
      throw RangeError.range(
        input,
        intConstraints.minInclusive,
        intConstraints.maxInclusive,
      );
    }

    return input.toString();
  }
}