import 'dart:convert';

import 'package:xsd/src/codecs/unsignedShort/config.dart';

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `unsignedShort` data type.
class UnsignedShortDecoder extends Converter<int, String> {
  const UnsignedShortDecoder();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < unsignedShortConstraints.minInclusive ||
        input > unsignedShortConstraints.maxInclusive) {
      throw RangeError.range(
        input,
        unsignedShortConstraints.minInclusive,
        unsignedShortConstraints.maxInclusive,
      );
    }

    return input.toString();
  }
}
