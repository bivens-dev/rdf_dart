import 'dart:convert';

import 'package:xsd/src/codecs/unsignedByte/config.dart';

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `unsignedByte` data type.
class UnsignedByteDecoder extends Converter<int, String> {
  const UnsignedByteDecoder();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < unsignedByteConstraints.minInclusive ||
        input > unsignedByteConstraints.maxInclusive) {
      throw RangeError.range(
        input,
        unsignedByteConstraints.minInclusive,
        unsignedByteConstraints.maxInclusive,
      );
    }
    return input.toString();
  }
}
