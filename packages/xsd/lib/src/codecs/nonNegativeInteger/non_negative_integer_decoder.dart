import 'dart:convert';

import 'package:xsd/src/codecs/nonNegativeInteger/config.dart';

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `nonNegativeInteger` data type.
class NonNegativeIntegerDecoder extends Converter<int, String> {
  const NonNegativeIntegerDecoder();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < nonNegativeIntegerConstraints.minInclusive) {
      throw RangeError.value(
        input,
        null,
        'must be greater than ${nonNegativeIntegerConstraints.minInclusive}',
      );
    }

    return input.toString();
  }
}