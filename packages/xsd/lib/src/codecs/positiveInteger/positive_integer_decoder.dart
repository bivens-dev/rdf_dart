import 'dart:convert';

import 'package:xsd/src/codecs/positiveInteger/config.dart';

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `positiveInteger` data type.
class PositiveIntegerDecoder extends Converter<int, String> {
  const PositiveIntegerDecoder();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < positiveIntegerConstraints.minInclusive) {
      throw RangeError.value(input, null, 'must be a positive number');
    }

    return input.toString();
  }
}