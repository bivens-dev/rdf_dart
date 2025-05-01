import 'dart:convert';

import 'package:xsd/src/codecs/unsignedInt/config.dart';

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `unsignedInt` data type.
class UnsignedIntDecoder extends Converter<int, String> {
  const UnsignedIntDecoder();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < unsignedIntConstraints.minInclusive ||
        input > unsignedIntConstraints.maxInclusive) {
      throw RangeError.range(
        input,
        unsignedIntConstraints.minInclusive,
        unsignedIntConstraints.maxInclusive,
      );
    }
    return input.toString();
  }
}
