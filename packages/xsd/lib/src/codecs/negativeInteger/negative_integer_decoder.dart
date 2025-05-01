import 'dart:convert';

import 'package:xsd/src/codecs/negativeInteger/config.dart';

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `negativeInteger` data type.
class NegativeIntegerDecoder extends Converter<int, String> {
  const NegativeIntegerDecoder();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input > negativeIntegerConstraints.maxInclusive) {
      throw RangeError.value(input, null, 'must be a negative number');
    }

    return input.toString();
  }
}
