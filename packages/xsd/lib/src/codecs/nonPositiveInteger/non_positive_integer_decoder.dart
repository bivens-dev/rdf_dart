import 'dart:convert';

import 'package:xsd/src/codecs/nonPositiveInteger/config.dart';

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `nonPositiveInteger` data type.
class NonPositiveIntegerDecoder extends Converter<int, String> {
  const NonPositiveIntegerDecoder();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input > nonPositiveIntegerConstraints.maxInclusive) {
      throw RangeError.value(
        input,
        null,
        'must be less than ${nonPositiveIntegerConstraints.maxInclusive}',
      );
    }

    return input.toString();
  }
}