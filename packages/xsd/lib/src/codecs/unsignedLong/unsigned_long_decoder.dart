import 'dart:convert';

import 'package:xsd/src/codecs/unsignedLong/config.dart';

/// A [Converter] for translating from Dart's [BigInt] data type back into a
/// [String] that represents a valid XML Schema `unsignedLong` data type.
class UnsignedLongDecoder extends Converter<BigInt, String> {
  const UnsignedLongDecoder();

  @override
  String convert(BigInt input) => _convert(input);

  String _convert(BigInt input) {
    if (input < unsignedLongConstraints.minInclusive ||
        input > unsignedLongConstraints.maxInclusive) {
      throw RangeError(
        'xsd:unsignedLong values must be between ${unsignedLongConstraints.minInclusive} and ${unsignedLongConstraints.maxInclusive}',
      );
    }
    return input.toString();
  }
}
