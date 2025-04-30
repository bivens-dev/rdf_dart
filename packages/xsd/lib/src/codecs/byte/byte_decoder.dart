import 'dart:convert';

import 'package:xsd/src/codecs/byte/config.dart';

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `byte` data type.
class ByteDecoder extends Converter<int, String> {
  const ByteDecoder();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < byteConstraints.minInclusive ||
        input > byteConstraints.maxInclusive) {
      throw RangeError.range(
        input,
        byteConstraints.minInclusive,
        byteConstraints.maxInclusive,
      );
    }

    return input.toString();
  }
}